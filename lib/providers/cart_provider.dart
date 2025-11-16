import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'quantity': quantity};
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  String? _userId;
  StreamSubscription? _authSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // napalitan/module 15
  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  // napalitan/module 15
  double get subtotal {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  // 2. ADD this new getter for VAT (12%)/module 15
  double get vat {
    return subtotal * 0.12; // 12% of the subtotal
  }

  // 3. ADD this new getter for the FINAL total/module 15
  double get totalPriceWithVat {
    return subtotal + vat;
  }

  // 2. ADD this new EMPTY constructor/module 12.5
  CartProvider() {
    print('CartProvider created.');
  }

  // 3. ADD this new PUBLIC method. We moved all the logic here/module 12.5
  void initializeAuthListener() {
    print('CartProvider auth listener initialized');
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User logged out, clearing cart.');
        _userId = null;
        _items = [];
      } else {
        print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }

  // Fetch cart from Firestore/ module 9
  Future<void> _fetchCart() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();

      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        print('Cart fetched successfully: ${_items.length} items');
      } else {
        _items = [];
      }
    } catch (e) {
      print('Error fetching cart: $e');
      _items = [];
    }

    notifyListeners();
  }

  // Save current cart to Firestore/module 9
  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      final List<Map<String, dynamic>> cartData = _items
          .map((item) => item.toJson())
          .toList();

      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });

      print('Cart saved to Firestore');
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // binago from module 9 to module 14
  void addItem(String id, String name, double price, int quantity) {
    var index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(id: id, name: name, price: price, quantity: quantity),
      );
    }

    _saveCart(); // This is the same
    notifyListeners(); // This is the same
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);

    _saveCart();
    notifyListeners();
  }

  // Place Order/module 10
  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      final List<Map<String, dynamic>> cartData = _items
          .map((item) => item.toJson())
          .toList();

      // nadagdagan/module 15
      final double sub = subtotal;
      final double v = vat;
      final double total = totalPriceWithVat;
      final int count = itemCount;

      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData,
        'subtotal': sub, // 3. ADD THIS/module 15
        'vat': v, // 4. ADD THIS/module 15
        'totalPrice': total,
        'itemCount': count,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Order placed successfully!');
    } catch (e) {
      print('Error placing order: $e');
      throw e;
    }
  }

  // Clear Cart/module 10
  Future<void> clearCart() async {
    _items = [];

    if (_userId != null) {
      try {
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        print('Firestore cart cleared.');
      } catch (e) {
        print('Error clearing Firestore cart: $e');
      }
    }

    notifyListeners();
  }

  // Dispose to cancel auth subscription/module 9
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
