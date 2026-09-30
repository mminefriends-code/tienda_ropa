import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/utils/product_media_helper.dart';
import 'virtual_fitting_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedTalla;
  String? _selectedColor;
  List<BranchAvailability> _sucursales = [];
  bool _loadingStock = true;

  @override
  void initState() {
    super.initState();
    if (widget.product.tallas.isNotEmpty) _selectedTalla = widget.product.tallas.first;
    if (widget.product.colores.isNotEmpty) _selectedColor = widget.product.colores.first;

    Future.microtask(() async {
      final list = await context.read<CatalogProvider>().fetchAvailability(widget.product.codigo);
      if (mounted) {
        setState(() {
          _sucursales = list;
          _loadingStock = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cart = context.read<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(p.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_in_ar, color: AppTheme.accent),
            tooltip: 'Probar en Vestidor RA',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VirtualFittingScreen(product: p)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del producto
            Container(
              height: 280,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF1F5F9),
              child: Center(
                child: ProductMediaHelper.fromProduct(
                  p,
                  color: _selectedColor,
                  fit: BoxFit.contain,
                  fallbackWidget: const Center(
                    child: Icon(Icons.checkroom, size: 70, color: Colors.black26),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBorder,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.categoria ?? 'Ropa',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Cód: ${p.codigo}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.nombre,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${p.precioFinal.toStringAsFixed(2)} Bs.',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Selector de Tallas
                  Text('Talla:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: p.tallas.map((t) {
                      final isSelected = t == _selectedTalla;
                      return ChoiceChip(
                        label: Text(t),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _selectedTalla = t),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Selector de Colores
                  Text('Color:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: p.colores.map((c) {
                      final isSelected = c == _selectedColor;
                      return ChoiceChip(
                        label: Text(c),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _selectedColor = c),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Disponibilidad en Sucursales Físicas
                  Text('Disponibilidad por Sucursal Física:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
                  const SizedBox(height: 10),
                  if (_loadingStock)
                    const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                  else if (_sucursales.isEmpty)
                    const Text('Consultando existencias de red...')
                  else
                    Column(
                      children: _sucursales.map((suc) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.store, color: AppTheme.accent, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${suc.nombre} (${suc.ciudad})',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      suc.direccion,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Disponible',
                                  style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.cardBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.view_in_ar),
                label: const Text('Vestidor RA'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VirtualFittingScreen(product: p)),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Al Carrito'),
                onPressed: () {
                  cart.addItem(
                    product: p,
                    talla: _selectedTalla ?? 'M',
                    color: _selectedColor ?? 'Negro',
                    idPtc: p.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡${p.nombre} agregado al carrito!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
