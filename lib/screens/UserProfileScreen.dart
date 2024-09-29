import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:teamproject_3/screens/login_screen.dart'; // นำเข้า LoginScreen

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // ดึงข้อมูลผู้ใช้ปัจจุบันจาก FirebaseAuth

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ผู้ใช้'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // รูปโปรไฟล์ (ถ้ามี)
            Center(
              child: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                radius: 60,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 60)
                    : null, // ใช้ไอคอนถ้าไม่มีรูป
              ),
            ),
            const SizedBox(height: 20),
            // แสดงชื่อผู้ใช้ (ถ้ามี)
            Text(
              'ชื่อผู้ใช้: ${user?.displayName ?? 'ไม่ระบุชื่อ'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // แสดงอีเมลผู้ใช้ที่ตรงกับที่ login
            Text(
              'อีเมล: ${user?.email ?? 'ไม่ระบุอีเมล'}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            // สถานะการเข้าสู่ระบบ
            Text(
              'สถานะ: ${user != null ? 'เข้าสู่ระบบแล้ว' : 'ยังไม่ได้เข้าสู่ระบบ'}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            // ปุ่ม Logout
            ElevatedButton(
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                'ออกจากระบบ',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
