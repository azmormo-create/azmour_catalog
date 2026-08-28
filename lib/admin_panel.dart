import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final Color gold = const Color(0xFFD4AF37);
  final Color black = const Color(0xFF0A0A0A);
  final String adminPassword = '1234'; // غيّر كلمة المرور
  
  TextEditingController passwordController = TextEditingController();
  bool isAuthenticated = false;

  void authenticate() {
    if (passwordController.text == adminPassword) {
      setState(() => isAuthenticated = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('تم الدخول بنجاح'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('كلمة المرور خاطئة'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: black,
        appBar: AppBar(
          backgroundColor: black,
          elevation: 0,
          title: Text('لوحة الإدارة', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: gold),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: !isAuthenticated
            ? loginScreen()
            : ProductManagementScreen(gold: gold, black: black),
      ),
    );
  }

  Widget loginScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 60, color: gold),
            const SizedBox(height: 30),
            Text('إدارة المنتجات', style: TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: passwordController,
              obscureText: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'أدخل كلمة المرور',
                hintStyle: TextStyle(color: gold.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: gold),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: gold, width: 1.5),
                ),
              ),
              style: TextStyle(color: gold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: authenticate,
              child: const Text('دخول', style: TextStyle(color: Color(0xFF0A0A0A), fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductManagementScreen extends StatefulWidget {
  final Color gold;
  final Color black;

  const ProductManagementScreen({
    super.key,
    required this.gold,
    required this.black,
  });

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> categories = ['بريما', 'لويا', 'اكوا ستار', 'العود', 'فيولا', 'مكانس', 'منتجات أخرى'];
  String selectedCategory = 'بريما';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: DropdownButton<String>(
            value: selectedCategory,
            dropdownColor: const Color(0xFF1C1C1C),
            isExpanded: true,
            items: categories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat, style: TextStyle(color: widget.gold)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedCategory = value);
              }
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('categories').doc(selectedCategory).collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: widget.gold));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 60, color: widget.gold.withOpacity(0.5)),
                      const SizedBox(height: 10),
                      Text('لا توجد منتجات', style: TextStyle(color: widget.gold.withOpacity(0.7))),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return productTile(doc.id, data);
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.gold,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              showAddProductDialog();
            },
            icon: const Icon(Icons.add, color: Color(0xFF0A0A0A)),
            label: const Text('إضافة منتج', style: TextStyle(color: Color(0xFF0A0A0A), fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget productTile(String docId, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: widget.gold.withOpacity(0.3)),
        ),
        child: ListTile(
          title: Text(data['name'] ?? '', style: TextStyle(color: widget.gold, fontWeight: FontWeight.bold)),
          subtitle: Text('السعر: ${data['price']} | الكمية: ${data['quantity']}', 
            style: TextStyle(color: widget.gold.withOpacity(0.7))),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: widget.gold),
                onPressed: () => showEditProductDialog(docId, data),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteProduct(docId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        category: selectedCategory,
        gold: widget.gold,
        black: widget.black,
      ),
    ).then((_) => setState(() {}));
  }

  void showEditProductDialog(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => EditProductDialog(
        docId: docId,
        category: selectedCategory,
        data: data,
        gold: widget.gold,
        black: widget.black,
      ),
    ).then((_) => setState(() {}));
  }

  void deleteProduct(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: Text('حذف المنتج', style: TextStyle(color: widget.gold)),
        content: Text('هل أنت متأكد من حذف هذا المنتج؟', style: TextStyle(color: widget.gold.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: widget.gold)),
          ),
          TextButton(
            onPressed: () {
              firestore.collection('categories').doc(selectedCategory).collection('products').doc(docId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف المنتج'), backgroundColor: Colors.green),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddProductDialog extends StatefulWidget {
  final String category;
  final Color gold;
  final Color black;

  const AddProductDialog({
    super.key,
    required this.category,
    required this.gold,
    required this.black,
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => selectedImage = File(pickedFile.path));
    }
  }

  Future<void> addProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    String imageUrl = '';
    if (selectedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref();
        final categoryRef = storageRef.child('${widget.category}/${nameController.text}.jpg');
        await categoryRef.putFile(selectedImage!);
        imageUrl = await categoryRef.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    final productData = {
      'name': nameController.text,
      'price': double.parse(priceController.text),
      'quantity': int.parse(quantityController.text),
      'description': descriptionController.text,
      'image': imageUrl,
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.category)
        .collection('products')
        .add(productData);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إضافة المنتج بنجاح'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: Text('إضافة منتج جديد', style: TextStyle(color: widget.gold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'اسم المنتج',
                  hintStyle: TextStyle(color: widget.gold.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: widget.gold),
                  ),
                ),
                style: TextStyle(color: widget.gold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'السعر',
                  hintStyle: TextStyle(color: widget.gold.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: widget.gold),
                  ),
                ),
                style: TextStyle(color: widget.gold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'الكمية',
                  hintStyle: TextStyle(color: widget.gold.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: widget.gold),
                  ),
                ),
                style: TextStyle(color: widget.gold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'الوصف',
                  hintStyle: TextStyle(color: widget.gold.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: widget.gold),
                  ),
                ),
                style: TextStyle(color: widget.gold),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    border: Border.all(color: widget.gold),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.image_outlined, color: widget.gold, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        selectedImage == null ? 'اختر صورة' : 'تم اختيار صورة',
                        style: TextStyle(color: widget.gold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: widget.gold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.gold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: addProduct,
            child: const Text('إضافة', style: TextStyle(color: Color(0xFF0A0A0A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class EditProductDialog extends StatefulWidget {
  final String docId;
  final String category;
  final Map<String, dynamic> data;
  final Color gold;
  final Color black;

  const EditProductDialog({
    super.key,
    required this.docId,
    required this.category,
    required this.data,
    required this.gold,
    required this.black,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController descriptionController;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name'] ?? '');
    priceController = TextEditingController(text: widget.data['price']?.toString() ?? '');
    quantityController = TextEditingController(text: widget.data['quantity']?.toString() ?? '');
    descriptionController = TextEditingController(text: widget.data['description'] ?? '');
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => selectedImage = File(pickedFile.path));
    }
  }

  Future<void> updateProduct() async {
    String imageUrl = widget.data['image'] ?? '';
    if (selectedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref();
        final categoryRef = storageRef.child('${widget.category}/${nameController.text}.jpg');
        await categoryRef.putFile(selectedImage!);
        imageUrl = await categoryRef.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    final productData = {
      'name': nameController.text,
      'price': double.parse(priceController.text),
      'quantity': int.parse(quantityController.text),
      'description': descriptionController.text,
      'image': imageUrl,
    };

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.category)
        .collection('products')
        .doc(widget.docId)
        .update(productData);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث المنتج بنجاح'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: Text('تعديل المنتج', style: TextStyle(color: widget.gold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'اسم المنتج',
                  hintStyle: TextStyle(color: widget.gold.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: widget.gold),
                  ),
                ),
                style: TextStyle(color: widget.gold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'السعر',
                  hintStyle: TextStyle(color: widget.gold.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: widget.gold),
                  ),
                ),
                style: TextStyle(color: widget.gold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'الكمية',
                  hintStyle: TextStyle(color: widget.gold.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: widget.gold),
                  ),
                ),
                style: TextStyle(color: widget.gold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'الوصف',
                  hintStyle: TextStyle(color: widget.gold.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: widget.gold),
                  ),
                ),
                style: TextStyle(color: widget.gold),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    border: Border.all(color: widget.gold),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.image_outlined, color: widget.gold, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        selectedImage == null ? 'تغيير الصورة' : 'تم اختيار صورة جديدة',
                        style: TextStyle(color: widget.gold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: widget.gold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.gold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: updateProduct,
            child: const Text('تحديث', style: TextStyle(color: Color(0xFF0A0A0A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
