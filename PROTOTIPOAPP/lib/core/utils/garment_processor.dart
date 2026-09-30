import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ProcessedGarment {
  final ui.Image image;
  final double width;
  final double height;
  final double aspectRatio;

  ProcessedGarment({
    required this.image,
    required this.width,
    required this.height,
  }) : aspectRatio = (width > 0 && height > 0) ? (width / height) : 0.82;
}

class GarmentProcessor {
  static final Map<String, ProcessedGarment> _cache = {};

  /// Carga y recorta inteligentemente el fondo de la prenda (fondo blanco/gris de estudio)
  /// eliminando el 100% de la caja blanca y ajustando la silueta ceñida idéntico a la web (VestidorRa.tsx).
  static Future<ProcessedGarment?> processGarment(String imagePathOrUrl) async {
    if (_cache.containsKey(imagePathOrUrl)) {
      return _cache[imagePathOrUrl];
    }

    try {
      Uint8List rawBytes;
      if (imagePathOrUrl.startsWith('http://') || imagePathOrUrl.startsWith('https://')) {
        final res = await http.get(Uri.parse(imagePathOrUrl)).timeout(const Duration(seconds: 8));
        if (res.statusCode != 200) return null;
        rawBytes = res.bodyBytes;
      } else {
        // Asset local
        final data = await rootBundle.load(imagePathOrUrl);
        rawBytes = data.buffer.asUint8List();
      }

      final codec = await ui.instantiateImageCodec(rawBytes);
      final frame = await codec.getNextFrame();
      final origImg = frame.image;

      final w = origImg.width;
      final h = origImg.height;

      final byteData = await origImg.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return null;

      // Crear copia mutable en memoria para manipular canales RGBA
      final pixels = Uint8List.fromList(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      int idx(int x, int y) => (y * w + x) * 4;

      // 1. Muestrear los bordes exteriores para obtener color de fondo predominante
      int rSum = 0, gSum = 0, bSum = 0, samples = 0;
      for (int x = 0; x < w; x += 3) {
        final iTop = idx(x, 0);
        final iBottom = idx(x, h - 1);
        rSum += pixels[iTop] + pixels[iBottom];
        gSum += pixels[iTop + 1] + pixels[iBottom + 1];
        bSum += pixels[iTop + 2] + pixels[iBottom + 2];
        samples += 2;
      }
      for (int y = 0; y < h; y += 3) {
        final iLeft = idx(0, y);
        final iRight = idx(w - 1, y);
        rSum += pixels[iLeft] + pixels[iRight];
        gSum += pixels[iLeft + 1] + pixels[iRight + 1];
        bSum += pixels[iLeft + 2] + pixels[iRight + 2];
        samples += 2;
      }

      final bgR = samples > 0 ? (rSum / samples).round() : 255;
      final bgG = samples > 0 ? (gSum / samples).round() : 255;
      final bgB = samples > 0 ? (bSum / samples).round() : 255;

      const tol = 60;
      const tolSq = tol * tol;

      final visited = Uint8List(w * h);
      final queue = <int>[];

      void enqueue(int x, int y) {
        if (x < 0 || y < 0 || x >= w || y >= h) return;
        final p = y * w + x;
        if (visited[p] == 1) return;
        visited[p] = 1;
        queue.add(p);
      }

      // Encolar los 4 bordes exteriores
      for (int x = 0; x < w; x++) {
        enqueue(x, 0);
        enqueue(x, h - 1);
      }
      for (int y = 0; y < h; y++) {
        enqueue(0, y);
        enqueue(w - 1, y);
      }

      // Flood-fill desde los bordes para eliminar fondo continuo de estudio
      int head = 0;
      while (head < queue.length) {
        final p = queue[head++];
        final x = p % w;
        final y = p ~/ w;
        final pi = p * 4;

        final r = pixels[pi];
        final g = pixels[pi + 1];
        final b = pixels[pi + 2];
        final a = pixels[pi + 3];

        if (a < 15) {
          enqueue(x + 1, y);
          enqueue(x - 1, y);
          enqueue(x, y + 1);
          enqueue(x, y - 1);
          continue;
        }

        final dr = r - bgR;
        final dg = g - bgG;
        final db = b - bgB;
        final distSq = dr * dr + dg * dg + db * db;

        // Detección de fondo de estudio (blanco / gris claro / fuera de foco)
        final isStudioWhite = r > 185 && g > 185 && b > 185 && (r - g).abs() < 30 && (r - b).abs() < 30;
        final isBackground = distSq <= tolSq || isStudioWhite;

        if (isBackground) {
          pixels[pi + 3] = 0; // Transparente 100%
          enqueue(x + 1, y);
          enqueue(x - 1, y);
          enqueue(x, y + 1);
          enqueue(x, y - 1);
        }
      }

      // Barrido de seguridad general: cualquier píxel de fondo blanco exterior aislado se vuelve transparente
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final pi = idx(x, y);
          final r = pixels[pi];
          final g = pixels[pi + 1];
          final b = pixels[pi + 2];
          if (r > 215 && g > 215 && b > 215 && (r - g).abs() < 22 && (r - b).abs() < 22) {
            pixels[pi + 3] = 0;
          }
        }
      }

      // 2. Encontrar caja de recorte ceñida (Tight Bounding Box)
      int minX = w, minY = h, maxX = 0, maxY = 0;
      bool hasGarment = false;

      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final a = pixels[idx(x, y) + 3];
          if (a > 30) {
            hasGarment = true;
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }

      if (!hasGarment || maxX <= minX || maxY <= minY) {
        minX = 0;
        minY = 0;
        maxX = w - 1;
        maxY = h - 1;
      } else {
        // Añadir margen mínimo de 2px
        minX = (minX - 2).clamp(0, w - 1);
        minY = (minY - 2).clamp(0, h - 1);
        maxX = (maxX + 2).clamp(0, w - 1);
        maxY = (maxY + 2).clamp(0, h - 1);
      }

      final cropW = maxX - minX + 1;
      final cropH = maxY - minY + 1;
      final cropPixels = Uint8List(cropW * cropH * 4);

      for (int y = 0; y < cropH; y++) {
        final srcY = minY + y;
        for (int x = 0; x < cropW; x++) {
          final srcX = minX + x;
          final srcPi = idx(srcX, srcY);
          final dstPi = (y * cropW + x) * 4;

          cropPixels[dstPi] = pixels[srcPi];
          cropPixels[dstPi + 1] = pixels[srcPi + 1];
          cropPixels[dstPi + 2] = pixels[srcPi + 2];
          cropPixels[dstPi + 3] = pixels[srcPi + 3];
        }
      }

      // Reconstruir imagen ceñida recortada y transparente
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        cropPixels,
        cropW,
        cropH,
        ui.PixelFormat.rgba8888,
        (img) => completer.complete(img),
      );

      final cleanImage = await completer.future;
      final processed = ProcessedGarment(
        image: cleanImage,
        width: cropW.toDouble(),
        height: cropH.toDouble(),
      );

      _cache[imagePathOrUrl] = processed;
      return processed;
    } catch (e) {
      debugPrint('Error en GarmentProcessor: $e');
      return null;
    }
  }
}
