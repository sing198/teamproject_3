import 'package:flutter/material.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';

class AddRecordScreen extends StatefulWidget {
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
      appBar: AppBar(title: Text('เพิ่มรายการ')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'รายละเอียด'),
                onChanged: (val) => description = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'จำนวนเงิน'),
                keyboardType: TextInputType.number,
                onChanged: (val) => amount = double.parse(val),
              ),
              DropdownButtonFormField<String>(
                value: type,
                items: ['รายรับ', 'รายจ่าย', 'การออม']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (val) => type = val!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final newRecord = FinancialRecord(
                    description: description,
                    amount: amount,
                    type: type,
                    date: DateTime.now(), // เพิ่มค่า date เป็นวันที่ปัจจุบัน
                  );
                  financialData.addRecord(newRecord);
                  Navigator.pop(context);
                },
                child: Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
