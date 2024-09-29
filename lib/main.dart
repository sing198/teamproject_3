import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/screens/login_screen.dart';
import 'package:teamproject_3/providers/financial_provider.dart';
import 'package:teamproject_3/screens/financial_overview_screen.dart';
import 'package:teamproject_3/providers/user_provider.dart'; // นำเข้า UserProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FinanceManagerApp());
}

class FinanceManagerApp extends StatelessWidget {
  const FinanceManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinancialProvider()), // FinancialProvider
        ChangeNotifierProvider(create: (_) => UserProvider()), // เพิ่ม UserProvider
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'แอปจัดการการเงิน',
            home: AuthCheck(), // แสดง AuthCheck เพื่อตรวจสอบสถานะการล็อกอิน
          );
        },
      ),
    );
  }
}

// ส่วนของการตรวจสอบสถานะการล็อกอิน
class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // แสดงสถานะ Loading
        } else if (snapshot.hasData) {
          return const FinancialOverviewScreen(); // ถ้าผู้ใช้ล็อกอินแล้ว แสดง HomeScreen
        } else {
          return const LoginScreen(); // ถ้าผู้ใช้ยังไม่ล็อกอิน แสดง LoginScreen
        }
      },
    );
  }
}
