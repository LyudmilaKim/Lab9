import 'package:flutter/material.dart';

void main() {
  runApp(
    CartScope(
      notifier: CartProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CatalogScreen(),
      ),
    ),
  );
}

class Product {
  final String name;
  final double price;
  final IconData icon;

  const Product(this.name, this.price, this.icon);
}

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);
  int get count => _items.length;

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.price);

  bool contains(Product product) => _items.contains(product);

  void toggleItem(Product product) {
    if (_items.contains(product)) {
      _items.remove(product);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}

class CartScope extends InheritedNotifier<CartProvider> {
  const CartScope({
    super.key,
    required CartProvider super.notifier,
    required super.child,
  });

  static CartProvider of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CartScope>()
        : context.getInheritedWidgetOfExactType<CartScope>();

    assert(scope != null, 'CartScope not found in context');
    return scope!.notifier!;
  }
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  static const List<Product> products = [
    Product('iPhone 16 Pro', 1299.00, Icons.phone_iphone),
    Product('MacBook Air M3', 1099.00, Icons.laptop_mac),
    Product('AirPods Pro 2', 249.00, Icons.headphones),
    Product('Apple Watch Ultra', 799.00, Icons.watch),
    Product('iPad Pro 13"', 1299.00, Icons.tablet_mac),
    Product('Magic Keyboard', 349.00, Icons.keyboard),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${cart.count}'),
              isLabelVisible: cart.count > 0,
              child: const Icon(Icons.shopping_cart, size: 28),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final inCart = cart.contains(product);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                product.icon,
                color: inCart ? Colors.green : Colors.grey,
                size: 32,
              ),
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      inCart ? Colors.red.shade100 : Colors.blue.shade50,
                  foregroundColor: inCart ? Colors.red : Colors.blue,
                ),
                onPressed: () {
                  CartScope.of(context, listen: false).toggleItem(product);
                },
                child: Text(inCart ? 'Remove' : 'Add'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                CartScope.of(context, listen: false).clearAll();
              },
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              label: const Text('Clear All', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Cart is empty',
                    style: TextStyle(fontSize: 22, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.check_circle,
                              color: Colors.green, size: 28),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              CartScope.of(context, listen: false)
                                  .removeItem(item);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border(
                      top: BorderSide(color: Colors.green.shade200, width: 2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}