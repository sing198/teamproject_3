import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamproject_3/models/financial_record.dart';

class DatabaseService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addFinancialRecord(FinancialRecord record) async {
    if (uid == null) {
      throw Exception('ผู้ใช้ไม่ได้เข้าสู่ระบบ');
    }

    await userCollection
        .doc(uid)
        .collection('financial_records')
        .add(record.toMap());
  }

  Future<List<FinancialRecord>> getFinancialRecords() async {
    if (uid == null) {
      throw Exception('ผู้ใช้ไม่ได้เข้าสู่ระบบ');
    }

    QuerySnapshot snapshot = await userCollection
        .doc(uid)
        .collection('financial_records')
        .get();

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return FinancialRecord(
        id: doc.id,
        description: data['description'],
        amount: data['amount'],
        type: data['type'],
        date: DateTime.parse(data['date']),
      );
    }).toList();
  }

  // ฟังก์ชันสำหรับอัปเดตบันทึกการเงิน
  Future<void> updateFinancialRecord(FinancialRecord record) async {
    if (uid == null) {
      throw Exception('ผู้ใช้ไม่ได้เข้าสู่ระบบ');
    }

    await userCollection
        .doc(uid)
        .collection('financial_records')
        .doc(record.id)
        .update(record.toMap());
  }

  // ฟังก์ชันสำหรับลบบันทึกการเงิน
  Future<void> deleteFinancialRecord(String id) async {
    if (uid == null) {
      throw Exception('ผู้ใช้ไม่ได้เข้าสู่ระบบ');
    }

    await userCollection
        .doc(uid)
        .collection('financial_records')
        .doc(id)
        .delete();
  }
}
