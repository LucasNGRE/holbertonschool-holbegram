import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../methods/auth_methods.dart';
import 'home_screen.dart';

class AddPicture extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  const AddPicture({
    super.key,
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  State<AddPicture> createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPicture> {
  Uint8List? _image;

  void selectImageFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _image = bytes);
    }
  }

  void selectImageFromCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _image = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Center(
                child: const Text(
                  'Holbegram',
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    fontSize: 50,
                  ),
                ),
              ),
              Center(
                child: Image.asset('assets/images/logo.webp', width: 80, height: 60),
              ),
              const SizedBox(height: 24),
              Text(
                'Hello, ${widget.username} Welcome to Holbegram.',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose an image from your gallery or take a new one.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Center(
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? MemoryImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 64, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: selectImageFromGallery,
                    icon: const Icon(Icons.image_outlined, size: 36, color: Color(0xFFE63946)),
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    onPressed: selectImageFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined, size: 36, color: Color(0xFFE63946)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    String res = await AuthMethode().signUpUser(
                      email: widget.email,
                      password: widget.password,
                      username: widget.username,
                      file: _image,
                    );
                    if (!context.mounted) return;
                    if (res == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('success')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE63946),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
