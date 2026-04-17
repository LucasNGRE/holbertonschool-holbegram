import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';

class UploadImageScreen extends StatefulWidget {
  final String username;

  const UploadImageScreen({super.key, required this.username});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  Uint8List? _image;

  Future<void> _selectImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
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
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              Center(child: Image.asset('assets/images/seahorse.png', height: 80)),
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
                    onPressed: () => _selectImage(ImageSource.gallery),
                    icon: const Icon(Icons.image_outlined, size: 36),
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    onPressed: () => _selectImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 36),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ),
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
