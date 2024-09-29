import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamproject_3/screens/financial_overview_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  String errorMessage = ''; // เก็บข้อความผิดพลาด
  bool _isLoading = false;  // สถานะการโหลด

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // เริ่มการโหลด
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.trim(), password: password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FinancialOverviewScreen()),
        );
      } on FirebaseAuthException catch (e) {
        // จัดการข้อผิดพลาดจาก Firebase Auth
        setState(() {
          errorMessage = _getFirebaseErrorMessage(e.code);
          _isLoading = false; // หยุดการโหลดเมื่อเกิดข้อผิดพลาด
        });
      } catch (e) {
        setState(() {
          errorMessage = 'An unexpected error occurred: $e';
          _isLoading = false; // หยุดการโหลดเมื่อเกิดข้อผิดพลาด
        });
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // เริ่มการโหลด
      });
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FinancialOverviewScreen()),
        );
      } on FirebaseAuthException catch (e) {
        // จัดการข้อผิดพลาดจาก Firebase Auth
        setState(() {
          errorMessage = _getFirebaseErrorMessage(e.code);
          _isLoading = false; // หยุดการโหลดเมื่อเกิดข้อผิดพลาด
        });
      } catch (e) {
        setState(() {
          errorMessage = 'An unexpected error occurred: $e';
          _isLoading = false; // หยุดการโหลดเมื่อเกิดข้อผิดพลาด
        });
      }
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'อีเมลไม่ถูกต้อง';
      case 'user-disabled':
        return 'บัญชีถูกปิดใช้งาน';
      case 'user-not-found':
        return 'ไม่พบผู้ใช้ที่ตรงกับอีเมลนี้';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง';
      case 'email-already-in-use':
        return 'อีเมลนี้ถูกใช้งานแล้ว';
      case 'weak-password':
        return 'รหัสผ่านอ่อนเกินไป';
      default:
        return 'เกิดข้อผิดพลาด: $errorCode';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เข้าสู่ระบบ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'อีเมล'),
                onChanged: (val) => email = val,
                validator: (val) =>
                    val!.isEmpty ? 'กรุณากรอกอีเมล' : null, // ตรวจสอบอีเมล
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) => val!.length < 6
                    ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'
                    : null, // ตรวจสอบรหัสผ่าน
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator() // แสดง loading ขณะกำลังเข้าสู่ระบบ/สมัครสมาชิก
              else ...[
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('เข้าสู่ระบบ'),
                ),
                TextButton(
                  onPressed: _register,
                  child: const Text('สมัครสมาชิก'),
                ),
              ],
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ), // แสดงข้อความผิดพลาด
            ],
          ),
        ),
      ),
    );
  }
}
