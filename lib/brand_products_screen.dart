import 'package:flutter/material.dart';
import 'main.dart';

class BrandProductsScreen extends StatelessWidget {
  final String brandName;
  final List<Product> products;
  const BrandProductsScreen({super.key, required this.brandName, required this.products});

  @override
  Widget build(BuildContext context) {
    final Color gold = const Color(0xFFD4AF37);
    final Color black = const Color(0xFF0A0A0A);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: black,
        appBar: AppBar(
          backgroundColor: black,
          elevation: 0,
          iconTheme: IconThemeData(color: gold),
          title: Text('منتجات $brandName', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: products.isEmpty
            ? Center(child: Text('سيتم إضافة منتجات هذا القسم قريباً جداً للكتالوج', style: TextStyle(color: gold.withOpacity(0.5), fontSize: 16)))
            : ListView.builder(
                itemCount: products.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final p = products[index];

                  return Card(
                    color: const Color(0xFF141414),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      // تم تصحيح هذا السطر هندسياً لحمايته من تداخل الترجمة نهائياً
                      side: BorderSide(color: gold.withOpacity(0.4), width: 1),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(p.description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('📦 التعبئة: ${p.piecesInBox} قطعة بالصندوق', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const Spacer(),
                              Text('💧 الحجم: ${p.volumeMl} مل', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('💰 السعر: ${p.priceLYD.toStringAsFixed(2)} دينار ليبي / للصندوق', style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
