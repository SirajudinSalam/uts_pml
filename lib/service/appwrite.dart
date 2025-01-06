import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:instagram/model/post.dart';

import '../model/user.dart';
import '../screen/home.dart';
import '../screen/login.dart';

class AppwriteService {
  Client client = Client();
  late Account account;
  late Databases databases;
  late Storage storage;

  AppwriteService() {
    client
      ..setEndpoint('https://cloud.appwrite.io/v1') // Endpoint Appwrite Anda
      ..setProject("6728b042001a05315144"); // Project ID Appwrite Anda

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }
  // Fungsi untuk mendaftarkan pengguna baru
  Future<UserModel?> register(
      String email, String password, String name) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return UserModel(
        id: user.$id,
        name: user.name,
        email: user.email,
      );
    } on AppwriteException catch (e) {
      print(" gagal : $e");
      if (e.code == 409) {
        throw 'Email sudah digunakan, silahkan gunakan email lain';
      }
      throw 'Terjadi kesalahan saat register';
    }
  }

  // Fungsi untuk login pengguna
  Future<void> login(String email, String password, context) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      print('Login successful');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    } on AppwriteException catch (e) {
      print(e);
      if (e.code == 401) {
        throw 'Email dan password salah';
      }
      throw 'Terjadi kesalahan saat login, pastikan internet anda terhubung';
    }
  }

  // Logout pengguna
  Future<void> logout(context) async {
    try {
      await account.deleteSession(sessionId: 'current');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    } catch (e) {
      throw Exception('Gagal logout');
    }
  }

////////////////////// COMING SOON ////////////////////////////

  // Fungsi untuk membuat dokumen pengguna di database
  Future<void> createUserDocument(String userId, UserModel user) async {
    try {
      await databases.createDocument(
        databaseId: 'post',
        collectionId: 'post',
        documentId: userId,
        data: user.toMap(),
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuat dokumen pengguna');
    }
  }

  // Mendapatkan detail pengguna saat ini
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await account.get();
      return UserModel(
        id: user.$id,
        name: user.name,
        email: user.email,
      );
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna saat ini');
    }
  }

  // Fungsi untuk mendapatkan semua postingan
  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await databases.listDocuments(
        databaseId: 'post',
        collectionId: 'post',
        queries: [Query.orderDesc('\$createdAt')],
      );
      return response.documents
          .map((doc) => PostModel.fromMap(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      print("Error fetching posts: ${e.message}");
      return [];
    } catch (e) {
      print("Unexpected error: $e");
      return [];
    }
  }

  // Fungsi untuk membuat postingan baru
  Future<void> createPost(String title, String body, String user,
      {String? imagePath}) async {
    try {
      String? imageUrl;
      String? imageId;

      if (imagePath != null) {
        final responseImg = await storage.createFile(
          bucketId: 'instagrampostId',
          fileId: ID.unique(),
          file: InputFile.fromPath(
            path: imagePath,
            filename: imagePath.split('/').last,
          ),
        );

        imageUrl =
            'https://cloud.appwrite.io/v1/storage/buckets/${responseImg.bucketId}/files/${responseImg.$id}/view?project=6728b042001a05315144&mode=admin';

        imageId = responseImg.$id;
      }

      Map<String, dynamic> data = {
        'title': title,
        'user': user,
        'body': body,
        'image': imageUrl,
        'imageId': imageId,
      };

      await databases.createDocument(
        databaseId: 'post',
        collectionId: 'post',
        documentId: ID.unique(),
        data: data,
      );

      print("Post created successfully");
    } on AppwriteException catch (e) {
      print("Error creating post: ${e.message}");
      throw 'Gagal membuat postingan';
    }
  }

  // Fungsi untuk memperbarui postingan
  Future<void> updatePost(String id, String title, String body,
      {String? imagePath, String? oldImageId}) async {
    try {
      String? imageUrl;
      String? imageId;

      if (imagePath != null) {
        final responseImg = await storage.createFile(
          bucketId: 'instagrampostId',
          fileId: ID.unique(),
          file: InputFile.fromPath(
            path: imagePath,
            filename: imagePath.split('/').last,
          ),
        );

        imageUrl =
            'https://cloud.appwrite.io/v1/storage/buckets/${responseImg.bucketId}/files/${responseImg.$id}/view?project=6728b042001a05315144&mode=admin';
        imageId = responseImg.$id;

        // Hapus file lama jika ada
        if (oldImageId != null) {
          await storage.deleteFile(
            bucketId: 'instagrampostId',
            fileId: oldImageId,
          );
        }
      }

      Map<String, dynamic> data = {
        'title': title,
        'body': body,
        if (imageUrl != null) 'image': imageUrl,
        if (imageId != null) 'imageId': imageId,
      };

      await databases.updateDocument(
        databaseId: 'post',
        collectionId: 'post',
        documentId: id,
        data: data,
      );

      print("Post updated successfully");
    } on AppwriteException catch (e) {
      print("Error updating post: ${e.message}");
      throw 'Gagal memperbarui postingan';
    }
  }

  // Fungsi untuk menghapus postingan
  Future<void> deletePost(String id, {String? imageId}) async {
    try {
      // Hapus file jika ada
      if (imageId != null) {
        await storage.deleteFile(
          bucketId: 'instagrampostId',
          fileId: imageId,
        );
      }

      await databases.deleteDocument(
        databaseId: 'post',
        collectionId: 'post',
        documentId: id,
      );

      print("Post deleted successfully");
    } on AppwriteException catch (e) {
      print("Error deleting post: ${e.message}");
      throw 'Gagal menghapus postingan';
    }
  }
}
