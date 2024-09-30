import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:teamproject_3/screens/financial_details_screen.dart';
import 'package:teamproject_3/screens/financial_planning_screen.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';
import 'package:teamproject_3/screens/add_record_screen.dart';
import 'package:intl/intl.dart';
import 'package:teamproject_3/screens/UserProfileScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialOverviewScreen extends StatefulWidget {
  const FinancialOverviewScreen({super.key});

  @override
  _FinancialOverviewScreenState createState() =>
      _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends State<FinancialOverviewScreen> {
  bool _isLoading = true;
  String username = ''; // ตัวแปรเก็บชื่อผู้ใช้

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFinancialData();
    });
  }

  Future<void> _fetchFinancialData() async {
    try {
      final financialData =
          Provider.of<FinancialProvider>(context, listen: false);
      await financialData.fetchRecords();

      // ดึงข้อมูลผู้ใช้จาก Firebase Authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ดึงข้อมูล `username` จาก Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // ตรวจสอบว่ามี `username` ใน document หรือไม่
        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            username = userDoc['username'] ?? 'ไม่พบชื่อผู้ใช้';
          });
        }
      }
    } catch (e) {
      print('Error fetching financial data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('สรุปการเงิน', style: TextStyle(color: Colors.white)),
            InkWell( // ใช้ InkWell เพื่อให้กดได้
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(), // ไปยังหน้า UserProfileScreen
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    username.isNotEmpty ? username : 'username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8), // เว้นช่องว่างระหว่างชื่อผู้ใช้และรูปโปรไฟล์
                  CircleAvatar(
                    backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                        ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                        : const AssetImage('lib/assets/image/profile_pic.png') as ImageProvider,
                    radius: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                // แสดงข้อความเมื่อไม่มีข้อมูลการเงิน
                financialData.records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/assets/image/Cat_nomoney.png',
                              height: 150,
                              width: 150,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'ไม่มีข้อมูลการเงิน กรุณาเพิ่มรายการ',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Expanded( // ใช้ Expanded เพื่อให้ขยายเต็มที่
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            // Pie Chart section
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              height: 200,
                              width: double.infinity, // กำหนดความกว้างเต็มพื้นที่
                              child: PieChart(
                                PieChartData(
                                  sections: _createChartData(financialData.records),
                                  centerSpaceRadius: 60,
                                  sectionsSpace: 2,
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20), // เพิ่มช่องว่างระหว่างกราฟและปุ่ม
                            // ปุ่มดูรายละเอียด
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FinancialDetailsScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                                child: const Text('ดูรายละเอียด', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 10), // เพิ่มช่องว่างระหว่างปุ่ม
                            // ปุ่มวางแผนการเงิน
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FinancialPlannerApp(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                                child: const Text('วางแผนการเงิน', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // รายการทรานแซคชัน
                            Expanded(
                              child: ListView.builder(
                                itemCount: financialData.records.length,
                                itemBuilder: (context, index) {
                                  final record = financialData.records[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    color: Colors.grey[850],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    child: ListTile(
                                      leading: Icon(
                                        record.type == 'รายรับ'
                                            ? Icons.arrow_downward
                                            : record.type == 'รายจ่าย'
                                                ? Icons.arrow_upward
                                                : Icons.savings,
                                        color: record.type == 'รายรับ'
                                            ? Colors.green
                                            : record.type == 'รายจ่าย'
                                                ? Colors.red
                                                : Colors.blue,
                                      ),
                                      title: Text(record.type,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      subtitle: Text(
                                        '${DateFormat('dd/MM/yyyy').format(record.date)} - ${record.description}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      trailing: Text(
                                        '${record.amount.toStringAsFixed(2)} บาท',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: record.type == 'รายรับ'
                                                ? Colors.green
                                                : record.type == 'รายจ่าย'
                                                    ? Colors.red
                                                    : Colors.blue),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecordScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  List<PieChartSectionData> _createChartData(List<FinancialRecord> records) {
    Map<String, double> dataMap = {
      'รายรับ': 0,
      'รายจ่าย': 0,
      'การออม': 0,
    };

    for (var record in records) {
      dataMap[record.type] = dataMap[record.type]! + record.amount;
    }

    final Map<String, Color> colorMap = {
      'รายรับ': Colors.green,
      'รายจ่าย': Colors.red,
      'การออม': Colors.blue,
    };

    return dataMap.entries.map((entry) {
      final totalAmount = dataMap.values.reduce((a, b) => a + b);
      final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);
      final formattedAmount = entry.value.toStringAsFixed(2);

      String title = '${entry.key}\n$formattedAmount\n$percentage%';

      return PieChartSectionData(
        color: colorMap[entry.key]!,
        value: entry.value,
        title: title,
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}
