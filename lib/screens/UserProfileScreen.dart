import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // นำเข้า Firestore
import 'dart:io';
import 'dart:typed_data'; // สำหรับ Uint8List
import 'package:flutter/foundation.dart'; // สำหรับตรวจสอบว่าเป็นเว็บหรือมือถือ
import 'login_screen.dart'; // นำเข้า LoginScreen

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser; // ดึงข้อมูลผู้ใช้ที่ล็อกอินอยู่
  File? _imageFile;
  Uint8List? _webImage;
  String username = ''; // เพิ่มตัวแปรสำหรับชื่อผู้ใช้
  bool _isLoading = true; // ตัวแปรสำหรับสถานะการโหลด

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // เรียกฟังก์ชันเพื่อดึงชื่อผู้ใช้
  }

  Future<void> _fetchUsername() async {
    if (user != null) {
      // ดึงชื่อผู้ใช้จาก Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        username = doc['username'] ?? 'ไม่ระบุชื่อ'; // กำหนดค่าให้กับ username
        _isLoading = false; // เปลี่ยนสถานะการโหลด
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('โปรไฟล์ผู้ใช้'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      backgroundImage: _getImage(),
                      radius: 60,
                      backgroundColor: Colors.grey[700],
                      child: _imageFile == null && _webImage == null && user?.photoURL == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.8),
                        radius: 18,
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('บันทึกรูปโปรไฟล์', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 20),
              // แสดงชื่อผู้ใช้จากตัวแปร username
              Text(
                'ชื่อผู้ใช้: $username',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'อีเมล: ${user?.email ?? 'ไม่ระบุอีเมล'}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'สถานะ: ${user != null ? 'เข้าสู่ระบบแล้ว' : 'ยังไม่ได้เข้าสู่ระบบ'}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              // ปุ่ม Logout
              Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: () async {
                    // เรียก FirebaseAuth เพื่อออกจากระบบ
                    await FirebaseAuth.instance.signOut();
                    // หลังจาก logout นำผู้ใช้ไปที่หน้า Login
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.3),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text(
                    'ออกจากระบบ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getImage() {
    if (kIsWeb && _webImage != null) {
      return MemoryImage(_webImage!);
    } else if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (user?.photoURL != null) {
      return NetworkImage(user!.photoURL!);
    }
    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    if (kIsWeb) {
      // สำหรับเว็บเบราว์เซอร์
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _webImage = bytes;
          });
        }
      }
    } else {
      // สำหรับ Android / iOS
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      }
    }
  }

  Future<void> _uploadImage() async {
    if ((kIsWeb && _webImage == null) || (!kIsWeb && _imageFile == null) || user == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_profiles/${user!.uid}.jpg');
      UploadTask uploadTask;

      if (kIsWeb) {
        // สำหรับเว็บเบราว์เซอร์
        uploadTask = storageRef.putData(_webImage!);
      } else {
        // สำหรับ Android / iOS
        uploadTask = storageRef.putFile(_imageFile!);
      }

      final snapshot = await uploadTask;
      final photoURL = await snapshot.ref.getDownloadURL();

      await user!.updatePhotoURL(photoURL);
      await user!.reload();

      // ตรวจสอบการ mounted ของ widget ก่อนเรียก setState()
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}
