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

class FinancialOverviewScreen extends StatefulWidget {
  const FinancialOverviewScreen({super.key});

  @override
  _FinancialOverviewScreenState createState() =>
      _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends State<FinancialOverviewScreen> {
  bool _isLoading = true; 

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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('สรุปการเงิน', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('lib/assets/image/profile_pic.png') as ImageProvider,
              radius: 15,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : financialData.records.isEmpty
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
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    // Pie Chart section
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      height: 200, 
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
