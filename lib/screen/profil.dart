import 'package:flutter/material.dart';
import 'package:instagram/model/user.dart';
import 'package:instagram/screen/add_post.dart';
import 'package:instagram/screen/home.dart';

import '../service/appwrite.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AppwriteService _appwriteService = AppwriteService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Memuat data user saat ini
  }

  // Fungsi untuk mengambil data user
  Future<void> _loadCurrentUser() async {
    try {
      final user = await _appwriteService.getCurrentUser();
      setState(() {
        _user = user;
      });
    } catch (e) {
      print('Gagal memuat data pengguna: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gambar Profil
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _user!.id.isNotEmpty
                          ? const NetworkImage(
                              "https://i.pinimg.com/564x/29/b8/d2/29b8d250380266eb04be05fe21ef19a7.jpg") // Gantilah dengan URL gambar profil dari Appwrite
                          : null,
                      child: _user!.id.isEmpty
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Nama Pengguna
                    Text(
                      _user!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email Pengguna
                    Text(
                      _user!.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tombol Edit Profil

                    const SizedBox(height: 16),

                    // Tombol Logout
                    ElevatedButton(
                      onPressed: () async {
                        bool? confirmLogout = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi Logout'),
                              content:
                                  const Text('Apakah Anda yakin ingin logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmLogout == true) {
                          await _appwriteService.logout(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
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
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddPostPage(
                                user: _user?.name ?? "",
                              )),
                      (route) => false);
                },
                icon: const Icon(
                  Icons.home,
                  color: Colors.grey,
                )),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 16, color: Colors.black),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
