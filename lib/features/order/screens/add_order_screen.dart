class AddOrderScreen extends ConsumerStatefulWidget {
  const AddOrderScreen({super.key});

  @override
  ConsumerState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final addressController = TextEditingController();
  String? selectedProductId;
  String? notes;
  File? productImage;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        productImage = File(result.files.first.path!);
      });
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    final isSpecialOrder = selectedProductId == null || productImage != null;
    
    final orderData = {
      'affiliateId': FirebaseAuth.instance.currentUser!.uid,
      'customerName': customerNameController.text,
      'customerPhone': customerPhoneController.text,
      'address': addressController.text,
      'productId': selectedProductId ?? 'custom',
      'status': isSpecialOrder ? 'pending_admin' : 'pending',
      'commission': 0, // Will be calculated by admin
      'createdAt': FieldValue.serverTimestamp(),
      'notes': notes,
    };

    try {
      await FirebaseFirestore.instance.collection('orders').add(orderData);
      
      if (isSpecialOrder) {
        // Upload image if exists
        if (productImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('order_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await ref.putFile(productImage!);
          final url = await ref.getDownloadURL();
          // Update order with image URL
        }
      }
      
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب جديد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: customerNameController,
              hintText: 'اسم الزبون',
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: customerPhoneController,
              hintText: 'رقم الهاتف',
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: addressController,
              hintText: 'العنوان',
              maxLines: 2,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            // Product selection dropdown
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'اختر المنتج'),
                  items: snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList(),
                  onChanged: (value) => selectedProductId = value,
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('إرفاق صورة (لمنتج جديد)'),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'إرسال الطلب',
              onPressed: _submitOrder,
            ),
          ],
        ),
      ),
    );
  }
}