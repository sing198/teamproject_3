import 'package:flutter/material.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';

class EditRecordScreen extends StatefulWidget {
  final FinancialRecord record;

  const EditRecordScreen({super.key, required this.record});

  @override
  _EditRecordScreenState createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late String description, type;
  late double amount;

  @override
  void initState() {
    super.initState();
    description = widget.record.description;
    amount = widget.record.amount;
    type = widget.record.type;
  }

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขรายการ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
                onChanged: (val) => description = val,
              ),
              TextFormField(
                initialValue: amount.toString(),
                decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
                keyboardType: TextInputType.number,
                onChanged: (val) => amount = double.parse(val),
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
                  final updatedRecord = FinancialRecord(
                    id: widget.record.id,
                    description: description,
                    amount: amount,
                    type: type,
                    date: DateTime.now(), // เพิ่มค่า date เป็นวันที่ปัจจุบัน

                  );
                  financialData.updateRecord(updatedRecord);
                  Navigator.pop(context);
                },
                child: const Text('บันทึกการเปลี่ยนแปลง'),
              ),
              TextButton(
                onPressed: () {
                  financialData.deleteRecord(widget.record.id);
                  Navigator.pop(context);
                },
                child: const Text('ลบรายการ', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
