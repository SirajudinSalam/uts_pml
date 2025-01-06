import 'package:flutter/material.dart';
import 'package:instagram/model/post.dart';
import 'package:instagram/model/user.dart';
import 'package:instagram/screen/add_post.dart';
import 'package:instagram/screen/profil.dart';
import 'package:instagram/screen/update_post.dart';

import '../service/appwrite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppwriteService _appwriteService = AppwriteService();
  late Future<List<PostModel>> _postsFuture;

  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _postsFuture = _appwriteService.fetchPosts();
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

  Future<void> _logout() async {
    // Menampilkan dialog konfirmasi
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Tutup dialog dan kirim 'false'
              },
              child: const Text('Batal'),
            ),
            // Tombol Logout
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Tutup dialog dan kirim 'true'
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    // Eksekusi logout jika konfirmasi 'true'
    if (confirmLogout == true) {
      await _appwriteService.logout(context);
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
          'Instagram',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<PostModel>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available'));
          } else {
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _buildPostCard(post);
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddPostPage(user: _user?.name ?? "")),
                      (route) => false);
                },
                icon: const Icon(Icons.add_box_outlined)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
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

  void _editPost(PostModel post) {
    // Navigasi ke halaman edit
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UpdatePostPage(post: post), // Ganti sesuai ID post
      ),
    );
  }

  void _deletePost(String id) {
    // Tampilkan dialog konfirmasi
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Hapus Post'),
        content: const Text('Apakah Anda yakin ingin menghapus post ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logika hapus post
              _deletePostFromDatabase(id); // Ganti dengan ID post
              Navigator.pop(context); // Tutup dialog
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePostFromDatabase(String postId) async {
    try {
      await _appwriteService.deletePost(postId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post berhasil dihapus')),
      );
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus post: $e')),
      );
    }
  }

  Widget _buildPostCard(PostModel post) {
    return Card(
      elevation: 2.0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Text(
                  post.user ?? "", // Placeholder user name
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editPost(post); // Fungsi untuk mengedit
                    } else if (value == 'delete') {
                      _deletePost(post.id); // Fungsi untuk menghapus
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Post Image
          if (post.image != null)
            Image.network(
              post.image!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 200, color: Colors.grey),
            ),
          // Post Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              post.title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          // Post Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              post.body,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
