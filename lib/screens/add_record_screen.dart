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
      backgroundColor: Colors.grey[900], // พื้นหลังสีเข้ม
      appBar: AppBar(
        title: const Text(
          'เพิ่มรายการ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ช่องกรอก "รายละเอียด"
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'รายละเอียด',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (val) => description = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'กรุณากรอกรายละเอียด';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // ช่องกรอก "จำนวนเงิน"
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'จำนวนเงิน',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
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
              const SizedBox(height: 20),
              // เลือกประเภทของรายการ (รายรับ, รายจ่าย, การออม)
              DropdownButtonFormField<String>(
                value: type,
                dropdownColor: Colors.grey[800], // สีพื้นหลังของ Dropdown
                decoration: InputDecoration(
                  labelText: 'ประเภท',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: ['รายรับ', 'รายจ่าย', 'การออม']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(
                            label,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (val) => setState(() {
                  type = val!;
                }),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),
              // ปุ่มบันทึก
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('บันทึก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
