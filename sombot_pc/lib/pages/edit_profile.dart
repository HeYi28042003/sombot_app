import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;
  const EditProfilePage({required this.uid});

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
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
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
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
