import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'brand_products_screen.dart';

void main() {
  runApp(const MyApp());
}

class Product {
  final String id;
  final String name;
  final String description;
  final double priceLYD;
  final int piecesInBox;
  final int volumeMl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceLYD,
    required this.piecesInBox,
    required this.volumeMl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceLYD: (json['priceLYD'] ?? 0.0).toDouble(),
      piecesInBox: json['piecesInBox'] ?? 0,
      volumeMl: json['volumeMl'] ?? 0,
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
    fetchCloudProducts();
  }

  // دالة جلب الأسعار الحية من السيرفر السحابي تلقائياً عند فتح التطبيق
  Future<void> fetchCloudProducts() async {
    // رابط السيرفر السحابي المجاني المؤقت لبيانات شركة أزمور
    final String cloudUrl = "https://npoint.io";
    try {
      final response = await http.get(Uri.parse(cloudUrl));
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          primaData = decodedData.map((p) => Product.fromJson(p)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
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
                fetchCloudProducts();
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
