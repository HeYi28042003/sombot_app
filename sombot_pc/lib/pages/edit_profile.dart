// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;
  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    if (doc.exists) {
      final data = doc.data();
      _nameController.text = data?['name'] ?? '';
      _phoneController.text = data?['phone'] ?? '';
      _addressController.text = data?['address'] ?? '';
      _base64Image = data?['profileImageBase64'];
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'profileImageBase64': _base64Image,
      });

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Widget _buildProfileImage() {
    Widget imageWidget;

    if (_base64Image != null && _base64Image!.isNotEmpty) {
      final bytes = base64Decode(_base64Image!);
      imageWidget = CircleAvatar(
        radius: 50,
        backgroundImage: MemoryImage(bytes),
      );
    } else {
      imageWidget = const CircleAvatar(
        radius: 50,
        child: Icon(Icons.person, size: 50),
      );
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        imageWidget,
        IconButton(
          icon: const Icon(Icons.photo_camera, color: Colors.black),
          onPressed: _pickImage,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = themeNotifier.themeData;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: theme.unselectedWidgetColor,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.unselectedWidgetColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: _buildProfileImage()),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: theme.unselectedWidgetColor.withOpacity(0.5),
                  ),
                ),
                style: TextStyle(
                  color: theme.unselectedWidgetColor,
                ),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(
                    color: theme.unselectedWidgetColor.withOpacity(0.5),
                  ),
                ),
                style: TextStyle(
                  color: theme.unselectedWidgetColor,
                ),
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(
                    color: theme.unselectedWidgetColor.withOpacity(0.5),
                  ),
                ),
                style: TextStyle(
                  color: theme.unselectedWidgetColor,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(theme.primaryColor),
                    backgroundColor:
                        WidgetStatePropertyAll(theme.scaffoldBackgroundColor),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        color: theme.primaryColor,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
