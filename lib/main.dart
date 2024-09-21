import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart'; // Import the Provider package
import 'package:teamproject_3/screens/login_screen.dart'; // Import the LoginScreen
import 'package:teamproject_3/providers/financial_provider.dart'; // Import your FinancialProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(FinanceManagerApp());
}

class FinanceManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinancialProvider()), // Add your FinancialProvider here
      ],
      child: MaterialApp(
        title: 'แอปจัดการการเงิน',
        home: LoginScreen(), // เปลี่ยนไปหน้า LoginScreen ที่คุณต้องการ
      ),
    );
  }
}
