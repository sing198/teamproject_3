import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // ข้อมูลผู้ใช้ เช่น อีเมล ชื่อ รูปโปรไฟล์
  String _email = '';
  String _name = '';
  String _profilePictureUrl = '';

  // Getter สำหรับการเข้าถึงข้อมูล
  String get email => _email;
  String get name => _name;
  String get profilePictureUrl => _profilePictureUrl;

  // ฟังก์ชันเพื่ออัปเดตอีเมลของผู้ใช้
  void setEmail(String newEmail) {
    _email = newEmail;
    notifyListeners(); // แจ้งเตือนผู้ฟังเกี่ยวกับการเปลี่ยนแปลง
  }

  // ฟังก์ชันเพื่ออัปเดตชื่อของผู้ใช้
  void setName(String newName) {
    _name = newName;
    notifyListeners(); // แจ้งเตือนผู้ฟังเกี่ยวกับการเปลี่ยนแปลง
  }

  // ฟังก์ชันเพื่ออัปเดตรูปโปรไฟล์ของผู้ใช้
  void setProfilePictureUrl(String newUrl) {
    _profilePictureUrl = newUrl;
    notifyListeners(); // แจ้งเตือนผู้ฟังเกี่ยวกับการเปลี่ยนแปลง
  }

  // ฟังก์ชันในการโหลดข้อมูลผู้ใช้ (อาจจะดึงจาก Firebase หรือแหล่งข้อมูลอื่น)
  Future<void> loadUserData(String userId) async {
    // ตัวอย่างการดึงข้อมูลผู้ใช้ (คุณอาจต้องเปลี่ยนให้สอดคล้องกับฐานข้อมูลของคุณ)
    // เช่นการดึงข้อมูลจาก Firebase Firestore
    // final userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    // setEmail(userData['email']);
    // setName(userData['name']);
    // setProfilePictureUrl(userData['profilePictureUrl']);

    // ในที่นี้ขอให้เป็นตัวอย่างการตั้งค่าข้อมูลเริ่มต้น
    setEmail('john.doe@example.com');
    setName('John Doe');
    setProfilePictureUrl('https://example.com/profile_pic.png');
  }
}
