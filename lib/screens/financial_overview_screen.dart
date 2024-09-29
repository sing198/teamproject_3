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

class FinancialOverviewScreen extends StatefulWidget {
  const FinancialOverviewScreen({super.key});

  @override
  _FinancialOverviewScreenState createState() =>
      _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends State<FinancialOverviewScreen> {
  bool _isLoading = true; // สถานะการโหลด

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
      await financialData.fetchRecords(); // ดึงข้อมูล
    } catch (e) {
      // จัดการกรณีมีข้อผิดพลาดในการดึงข้อมูล
      print('Error fetching financial data: $e');
    } finally {
      setState(() {
        _isLoading = false; // หยุดการโหลดเมื่อดึงข้อมูลเสร็จ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('สรุปการเงิน'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile_pic.png'), // หรือใช้ NetworkImage ถ้ารูปมาจาก URL
              radius: 15,
            ),
            onPressed: () {
              // เมื่อกดที่ไอคอนโปรไฟล์ ให้ไปที่หน้าจอโปรไฟล์
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(), // ไปที่หน้าจอโปรไฟล์ผู้ใช้
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // แสดง loading
          : financialData.records.isEmpty
              ? const Center(
                  child: Text('ไม่มีข้อมูลการเงิน กรุณาเพิ่มรายการ',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                )
              : Column(
                  children: [
                    // ส่วนที่แสดง Pie Chart
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PieChart(
                          PieChartData(
                            sections: _createChartData(financialData.records),
                            centerSpaceRadius: 60,
                            sectionsSpace: 4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ปุ่มดูรายละเอียด
                    _buildButton(context, 'ดูรายละเอียด', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinancialDetailsScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    // ปุ่มวางแผนการเงิน
                    _buildButton(context, 'วางแผนการเงิน', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinancialPlannerApp(),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    // ส่วนที่แสดงรายการทรานแซคชัน
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: financialData.records.length,
                          itemBuilder: (context, index) {
                            final record = financialData.records[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
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
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${DateFormat('dd/MM/yyyy').format(record.date)} - ${record.description}'),
                                trailing: Text(
                                  '${record.amount.toStringAsFixed(2)} บาท',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: record.type == 'รายรับ'
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecordScreen()),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: Text(title),
      ),
    );
  }

  List<PieChartSectionData> _createChartData(List<FinancialRecord> records,
      {bool showPercentage = true, bool showAmount = true}) {
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

      String title = entry.key;
      if (showAmount && showPercentage) {
        title += '\n$formattedAmount บาท\n$percentage%';
      } else if (showAmount) {
        title += '\n$formattedAmount บาท';
      } else if (showPercentage) {
        title += '\n$percentage%';
      }

      return PieChartSectionData(
        color: colorMap[entry.key]!,
        value: entry.value,
        title: title,
        radius: 100,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}
