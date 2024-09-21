import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamproject_3/screens/financial_overview_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  String errorMessage = ''; // เก็บข้อความผิดพลาด

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.trim(), password: password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FinancialOverviewScreen()),
        );
      } catch (e) {
        setState(() {
          errorMessage = e.toString(); // แสดงข้อความผิดพลาด
        });
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FinancialOverviewScreen()),
        );
      } catch (e) {
        setState(() {
          errorMessage = e.toString(); // แสดงข้อความผิดพลาด
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('เข้าสู่ระบบ')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'อีเมล'),
                  onChanged: (val) => email = val,
                  validator: (val) =>
                      val!.isEmpty ? 'กรุณากรอกอีเมล' : null, // ตรวจสอบอีเมล
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'รหัสผ่าน'),
                  obscureText: true,
                  onChanged: (val) => password = val,
                  validator: (val) => val!.length < 6
                      ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'
                      : null, // ตรวจสอบรหัสผ่าน
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('เข้าสู่ระบบ'),
                ),
                TextButton(
                  onPressed: _register,
                  child: Text('สมัครสมาชิก'),
                ),
                SizedBox(height: 20),
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ), // แสดงข้อความผิดพลาด
              ],
            ),
          ),
        ));
  }
}
