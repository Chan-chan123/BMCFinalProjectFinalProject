import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/admin_panel_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/widgets/product_card.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/screens/order_history_screen.dart'; // New import galing module 11
import 'package:ecommerce_app/screens/profile_screen.dart'; // New import galing module 13
import 'package:ecommerce_app/widgets/notification_icon.dart'; // New import galing module 17
import 'package:ecommerce_app/screens/chat_screen.dart'; // New import galing module 18

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userRole = 'user';
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // nadagdag module 18

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _userRole = doc.data()!['role'];
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ClipOval(
          // NEW
          child: Image.asset(
            'assets/images/Piyora.png',
            height: 40,
            width: 40, // NEW: para pantay ang height at width
            fit: BoxFit.cover, // NEW: para hindi ma-stretch
          ),
        ),

        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Badge(
                label: Text(cart.itemCount.toString()),
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const NotificationIcon(), // galing sa module 17

          IconButton(
            // New Button/module 11
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),

          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),

          // inibang logout button/module 13
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found. Add some in the Admin Panel!'),
            );
          }
          final products = snapshot.data!.docs;
          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final productData = productDoc.data() as Map<String, dynamic>;
              return ProductCard(
                productName: productData['name'],
                price: productData['price'],
                imageUrl: productData['imageUrl'],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productData: productData,
                        productId: productDoc.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // nadagdag module 18
      floatingActionButton: _userRole == 'user'
          ? StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                int unreadCount = 0; // nadagdag module 18
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data();
                  if (data != null) {
                    // nadagdag module 18
                    unreadCount =
                        (data as Map<String, dynamic>)['unreadByUserCount'] ??
                        0;
                  }
                }

                // nadagdag module 18
                return Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  child: FloatingActionButton.extended(
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Admin'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(chatRoomId: _currentUser.uid), // tinanggalan ng !
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : null, // nadagdag module 18
    );
  }
}
