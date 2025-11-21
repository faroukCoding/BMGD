import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? user;

  const UserFormDialog({super.key, this.user});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone;
      _selectedRole = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.user == null) {
        // إنشاء مستخدم جديد
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: 'defaultPassword123', // يجب تغييره لاحقاً
        );

        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set({
          'id': credential.user!.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // تعديل مستخدم موجود
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(widget.user!.id)
            .update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole,
        });
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'إضافة مستخدم' : 'تعديل مستخدم'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'الاسم الكامل',
                validator: (value) => Validators.validateRequired(value, 'الاسم'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                hintText: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                enabled: widget.user == null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                hintText: 'رقم الهاتف',
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'اختر الدور',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.roleAdmin,
                    child: Text('مدير'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.roleAssistant,
                    child: Text('مساعد إداري'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.roleAffiliate,
                    child: Text('مسوّق'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.roleCallCenter,
                    child: Text('مؤكد طلبات'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.roleDriver,
                    child: Text('سائق'),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedRole = value),
                validator: (value) => value == null ? 'يجب اختيار دور' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveUser,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.user == null ? 'إضافة' : 'حفظ'),
        ),
      ],
    );
  }
}