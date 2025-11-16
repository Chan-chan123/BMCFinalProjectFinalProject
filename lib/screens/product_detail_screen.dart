import 'package:flutter/material.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget { // NEW: Converted to StatefulWidget
  final Map<String, dynamic> productData;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productData,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState(); // NEW
}

class _ProductDetailScreenState extends State<ProductDetailScreen> { // NEW

  int _quantity = 1; // NEW: Quantity state variable

  // NEW: Increment quantity
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  // NEW: Decrement quantity
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.productData['name']; // NEW: Access via widget
    final String description = widget.productData['description']; // NEW
    final String imageUrl = widget.productData['imageUrl']; // NEW
    final double price = widget.productData['price']; // NEW
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              imageUrl,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: Icon(Icons.broken_image, size: 100)),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),
                  Text(
                    'About this item',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 30),

                  // NEW: Quantity selector section
                  const SizedBox(height: 20), // NEW
                  Row( // NEW
                    mainAxisAlignment: MainAxisAlignment.center, // NEW
                    children: [ // NEW
                      IconButton.filledTonal( // NEW
                        icon: const Icon(Icons.remove), // NEW
                        onPressed: _decrementQuantity, // NEW
                      ), // NEW
                      Padding( // NEW
                        padding: const EdgeInsets.symmetric(horizontal: 20), // NEW
                        child: Text( // NEW
                          '$_quantity', // NEW
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // NEW
                        ), // NEW
                      ), // NEW
                      IconButton.filled( // NEW
                        icon: const Icon(Icons.add), // NEW
                        onPressed: _incrementQuantity, // NEW
                      ), // NEW
                    ], // NEW
                  ), // NEW
                  const SizedBox(height: 20), // NEW

                  ElevatedButton.icon(
                    onPressed: () {
                      cart.addItem(
                        widget.productId,
                        name,
                        price,
                        _quantity, // NEW: Pass quantity
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar( // NEW: Updated message
                          content: Text('Added $_quantity x $name to cart!'), // NEW
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
