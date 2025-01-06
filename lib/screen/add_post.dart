import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/model/post.dart';
import 'package:instagram/screen/home.dart';
import 'package:instagram/screen/profil.dart';

import '../service/appwrite.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key, required this.user});
  final String user;

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final AppwriteService _appwriteService = AppwriteService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false; // Tambahkan variabel untuk status loading

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

  Future<void> _addPost() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body cannot be empty')),
      );
      return;
    }

    // Mulai proses loading
    setState(() {
      _isLoading = true;
    });

    try {
      final newPost = PostModel(
        id: '',
        user: widget.user,
        title: _titleController.text,
        body: _bodyController.text,
        image: _selectedImage?.path,
        imageId: null,
      );

      await _appwriteService.createPost(
          newPost.title, newPost.body, widget.user,
          imagePath: newPost.image);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post added successfully')),
      );

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      // Matikan loading setelah selesai
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Post'),
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
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
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // Tombol dinonaktifkan saat loading
                      : _addPost,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        ) // Tampilkan indikator loading di tombol
                      : const Text(
                          'Upload Post',
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
          // Overlay loading di tengah layar
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false);
                },
                icon: const Icon(
                  Icons.home,
                  color: Colors.grey,
                )),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box_outlined,
              color: Colors.black,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                 Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage()),
                      (route) => false);
              },
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 16, color: Colors.grey),
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
