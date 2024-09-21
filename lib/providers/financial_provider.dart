import 'package:flutter/material.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:teamproject_3/services/database_service.dart';

class FinancialProvider with ChangeNotifier {
  List<FinancialRecord> _records = [];

  List<FinancialRecord> get records => _records;

  Future<void> fetchRecords() async {
    _records = await DatabaseService().getFinancialRecords();
    notifyListeners();
  }

  void addRecord(FinancialRecord record) {
    DatabaseService().addFinancialRecord(record);
    fetchRecords();
  }

  void updateRecord(FinancialRecord record) {
    DatabaseService().updateFinancialRecord(record);
    fetchRecords();
  }

  void deleteRecord(String id) {
    DatabaseService().deleteFinancialRecord(id);
    fetchRecords();
  }
}
