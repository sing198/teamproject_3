import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamproject_3/models/financial_record.dart';

class DatabaseService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addFinancialRecord(FinancialRecord record) async {
    await userCollection
        .doc(uid)
        .collection('financial_records')
        .add(record.toMap());
  }

  Future<List<FinancialRecord>> getFinancialRecords() async {
    final snapshot = await userCollection
        .doc(uid)
        .collection('financial_records')
        .get();

    return snapshot.docs
        .map((doc) => FinancialRecord.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> updateFinancialRecord(FinancialRecord record) async {
    await userCollection
        .doc(uid)
        .collection('financial_records')
        .doc(record.id)
        .update(record.toMap());
  }

  Future<void> deleteFinancialRecord(String id) async {
    await userCollection
        .doc(uid)
        .collection('financial_records')
        .doc(id)
        .delete();
  }
}
