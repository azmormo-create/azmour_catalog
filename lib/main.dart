import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'brand_products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class Product {
  final String id;
  final String name;
  final String package;
  final double price;
  final int piecesInBox;
  final int quantity;
  final List<String> scents;

  Product({
    required this.id,
    required this.name,
    required this.package,
    required this.price,
    required this.piecesInBox,
    required this.quantity,
    required this.scents,
  });

  factory Product.fromFirestore(Map<String, dynamic> json, String docId) {
    return Product(
      id: docId,
      name: json['name'] ?? '',
      package: json['package'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      piecesInBox: json['pieces_per_box'] ?? 0,
      quantity: json['quantity'] ?? 0,
      scents: List<String>.from(json['scents'] ?? []),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Azmour Catalog',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color gold = const Color(0xFFD4AF37);
  final Color black = const Color(0xFF0A0A0A);
  
  List<Product> primaData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFirebaseProducts();
  }

  // دالة جلب المنتجات من Firebase
  Future<void> fetchFirebaseProducts() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc('prima')
          .collection('shampoos')
          .get();

      setState(() {
        primaData = snapshot.docs
            .map((doc) => Product.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> brands = [
      {'name': 'بريما', 'src': 'assets/images/prima.png'},
      {'name': 'لويا', 'src': 'assets/images/loya.png'},
      {'name': 'العود', 'src': 'assets/images/aloud.png'},
      {'name': 'فيولا', 'src': 'assets/images/viola.png'},
      {'name': 'اكوا ستار', 'src': 'assets/images/aquastar.png'},
      {'name': 'مكانس', 'src': '🧹'},
      {'name': 'منتجات أخرى', 'src': '📦'},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: black,
        appBar: AppBar(
          backgroundColor: black,
          elevation: 0,
          title: Text('كتالوج شركة أزمور الذكي', style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 20)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: gold),
              onPressed: () {
                setState(() => isLoading = true);
                fetchFirebaseProducts();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/azmour_logo.png',
                width: 90,
                height: 90,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.business_center_rounded, size: 80, color: gold),
              ),
              const SizedBox(height: 10),
              Text('شركة أزمور للاستيراد والتوزيع', style: TextStyle(color: gold.withOpacity(0.8), fontSize: 16)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), child: Divider(color: gold, thickness: 0.5)),
              isLoading 
              ? Center(child: Padding(padding: const EdgeInsets.all(20.0), child: CircularProgressIndicator(color: gold)))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final b = brands[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BrandProductsScreen(
                                brandName: b['name']!,
                                products: b['name'] == 'بريما' ? primaData : [],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: gold, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(color: const Color(0xFF1C1C1C), shape: BoxShape.circle, border: Border.all(color: gold.withOpacity(0.5))),
                                child: Center(
                                  child: b['src']!.contains('.png')
                                      ? Image.asset(
                                          b['src']!,
                                          width: 45,
                                          height: 45,
                                          errorBuilder: (context, error, stackTrace) => Icon(Icons.image_search, color: gold, size: 26),
                                        )
                                      : Text(b['src']!, style: const TextStyle(fontSize: 35)),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(b['name']!, style: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Icon(Icons.arrow_forward_ios_rounded, color: gold, size: 16),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
