import 'package:flutter/material.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:teamproject_3/services/database_service.dart';

class FinancialProvider with ChangeNotifier {
  List<FinancialRecord> _records = [];

  List<FinancialRecord> get records => _records;

  // ดึงข้อมูลบันทึกการเงิน
  Future<void> fetchRecords() async {
    try {
      _records = await DatabaseService().getFinancialRecords();
      notifyListeners();
    } catch (e) {
      print("Error fetching records: $e");
    }
  }

  // เพิ่มบันทึกการเงิน
  Future<void> addRecord(FinancialRecord record) async {
    try {
      await DatabaseService().addFinancialRecord(record);
      _records.add(record);
      notifyListeners();
    } catch (e) {
      print("Error adding record: $e");
    }
  }

  // ฟังก์ชันใหม่: อัปเดตบันทึกการเงิน
  Future<void> updateRecord(FinancialRecord updatedRecord) async {
    try {
      await DatabaseService().updateFinancialRecord(updatedRecord); // เรียกใช้ชื่อที่ถูกต้อง
      int index = _records.indexWhere((record) => record.id == updatedRecord.id);
      if (index != -1) {
        _records[index] = updatedRecord; // อัปเดตข้อมูลในลิสต์
        notifyListeners(); // แจ้งเตือน UI ให้ปรับปรุงข้อมูล
      }
    } catch (e) {
      print("Error updating record: $e");
    }
  }

  // ฟังก์ชันใหม่: ลบบันทึกการเงิน
  Future<void> deleteRecord(String id) async {
    try {
      await DatabaseService().deleteFinancialRecord(id); // เรียกใช้ชื่อที่ถูกต้อง
      _records.removeWhere((record) => record.id == id); // ลบข้อมูลจากลิสต์
      notifyListeners();
    } catch (e) {
      print("Error deleting record: $e");
    }
  }
}
