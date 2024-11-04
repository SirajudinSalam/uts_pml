import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';
import '../screen/home.dart';
import '../screen/login.dart';

class AppwriteService {
  Client client = Client();
  late Account account;
  late Databases databases;

  AppwriteService() {
    client
      ..setEndpoint(
          'https://cloud.appwrite.io/v1') // Ganti dengan endpoint Appwrite Anda
      ..setProject(
          "6728b042001a05315144"); // Ganti dengan project ID Appwrite Anda

    account = Account(client);
    databases = Databases(client);
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
        databaseId: 'YOUR_DATABASE_ID',
        collectionId: 'YOUR_COLLECTION_ID',
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

  // Mengambil dokumen pengguna dari database
  Future<UserModel?> getUserDocument(String userId) async {
    try {
      final userDocument = await databases.getDocument(
        databaseId: 'YOUR_DATABASE_ID',
        collectionId: 'YOUR_COLLECTION_ID',
        documentId: userId,
      );
      return UserModel.fromMap(userDocument.data);
    } catch (e) {
      throw Exception('Gagal mengambil dokumen pengguna');
    }
  }

}
