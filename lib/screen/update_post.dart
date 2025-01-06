import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/post.dart';
import '../service/appwrite.dart';
import 'home.dart';

class UpdatePostPage extends StatefulWidget {
  final PostModel post;

  const UpdatePostPage({super.key, required this.post});

  @override
  State<UpdatePostPage> createState() => _UpdatePostPageState();
}

class _UpdatePostPageState extends State<UpdatePostPage> {
  final AppwriteService _appwriteService = AppwriteService();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  File? _selectedImage;
  bool _isLoading = false; // Variabel untuk melacak status loading

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _bodyController = TextEditingController(text: widget.post.body);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updatePost() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Mulai loading
    });

    try {
      await _appwriteService.updatePost(
        widget.post.id,
        _titleController.text,
        _bodyController.text,
        imagePath: _selectedImage?.path,
        oldImageId: widget.post.imageId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Selesai loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Update Post'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 1,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar yang diunggah
                  GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : widget.post.image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.post.image!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Input judul
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Input isi
                  TextField(
                    controller: _bodyController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Body',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tombol update
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updatePost,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: _isLoading ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Update Post',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
