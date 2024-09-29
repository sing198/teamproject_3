import 'package:flutter/material.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  _AddRecordScreenState createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  String description = '', type = 'รายรับ';
  double amount = 0.0;

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มรายการ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
                onChanged: (val) => description = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'กรุณากรอกรายละเอียด';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    amount = double.tryParse(val) ?? 0.0; // แปลงเป็น double
                  }
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'กรุณากรอกจำนวนเงิน';
                  } else if (double.tryParse(val) == null) {
                    return 'กรุณากรอกจำนวนเงินที่ถูกต้อง';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: type,
                items: ['รายรับ', 'รายจ่าย', 'การออม']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (val) => type = val!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) { // ตรวจสอบความถูกต้อง
                    final newRecord = FinancialRecord(
                      description: description,
                      amount: amount,
                      type: type,
                      date: DateTime.now(), // วันที่ปัจจุบัน
                    );
                    financialData.addRecord(newRecord); // บันทึกลง Firestore
                    Navigator.pop(context);
                  }
                },
                child: const Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
