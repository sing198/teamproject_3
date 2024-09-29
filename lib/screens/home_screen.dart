import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // ต้องมี const constructor

  @override
  Widget build(BuildContext context) {
    final financialProvider = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าแรก'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implement logout logic here if needed
            },
          ),
        ],
      ),
      body: financialProvider.records.isEmpty
          ? const Center(child: Text('ไม่มีข้อมูลการเงิน'))
          : ListView.builder(
              itemCount: financialProvider.records.length,
              itemBuilder: (context, index) {
                final record = financialProvider.records[index];
                return ListTile(
                  title: Text(record.description),
                  subtitle: Text('${record.amount} บาท'),
                );
              },
            ),
    );
  }
}

