import 'package:flutter/material.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:teamproject_3/screens/add_record_screen.dart';
import 'package:teamproject_3/screens/edit_record_screen.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';

class FinancialDetailsScreen extends StatelessWidget {
  const FinancialDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดการเงิน')),
      body: ListView.builder(
        itemCount: financialData.records.length,
        itemBuilder: (context, index) {
          final record = financialData.records[index];
          return ListTile(
            title: Text('${record.type}: ${record.amount}'),
            subtitle: Text(record.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditRecordScreen(record: record)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // ลบรายการเมื่อกดปุ่มถังขยะ
                    financialData.deleteRecord(record.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecordScreen()),
          );
        },
      ),
    );
  }
}
