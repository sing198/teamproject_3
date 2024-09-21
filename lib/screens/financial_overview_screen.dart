import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:teamproject_3/screens/financial_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';
import 'package:teamproject_3/screens/add_record_screen.dart';
import 'package:intl/intl.dart'; // สำหรับฟอร์แมตวันที่

class FinancialOverviewScreen extends StatefulWidget {
  @override
  _FinancialOverviewScreenState createState() =>
      _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends State<FinancialOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final financialData =
          Provider.of<FinancialProvider>(context, listen: false);
      financialData.fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('สรุปการเงิน')),
      body: financialData.records.isEmpty
          ? Center(
              child: Text('ไม่มีข้อมูลการเงิน กรุณาเพิ่มรายการ'),
            )
          : Column(
              children: [
                // ส่วนที่แสดง Pie Chart Dashboard
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: _createChartData(financialData.records),
                      centerSpaceRadius: 60,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                // ปุ่มกดดูรายละเอียด
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinancialDetailsScreen(),
                      ),
                    );
                  },
                  child: Text('ดูรายละเอียด'),
                ),
                // ส่วนที่แสดงรายการทรานแซคชัน
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: financialData.records.length,
                    itemBuilder: (context, index) {
                      final record = financialData.records[index];
                      return ListTile(
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
                        title: Text(record.type),
                        subtitle: Text(
                            '${DateFormat('dd/MM/yyyy').format(record.date)} - ${record.description}'),
                        trailing: Text(
                          '${record.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: record.type == 'รายรับ'
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecordScreen()),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _createChartData(
    List<FinancialRecord> records, 
    {bool showPercentage = true, bool showAmount = true}) {

  // Map ที่ใช้เก็บยอดรวมของแต่ละประเภท
  Map<String, double> dataMap = {
    'รายรับ': 0,
    'รายจ่าย': 0,
    'การออม': 0,
  };

  // สรุปยอดรวมตามประเภท
  for (var record in records) {
    dataMap[record.type] = dataMap[record.type]! + record.amount;
  }

  // กำหนดสีสำหรับแต่ละประเภท
  final Map<String, Color> colorMap = {
    'รายรับ': Colors.green,
    'รายจ่าย': Colors.red,
    'การออม': Colors.blue,
  };

  // สร้างข้อมูลสำหรับ Pie Chart
  return dataMap.entries.map((entry) {
    final totalAmount = dataMap.values.reduce((a, b) => a + b);
    final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);
    final formattedAmount = entry.value.toStringAsFixed(2);

    // สร้าง title ตามเงื่อนไขที่เลือก
    String title = entry.key;
    if (showAmount && showPercentage) {
      title += '\n$formattedAmount บาท\n$percentage%';
    } else if (showAmount) {
      title += '\n$formattedAmount บาท';
    } else if (showPercentage) {
      title += '\n$percentage%';
    }

    return PieChartSectionData(
      color: colorMap[entry.key]!,  // ใช้สีที่กำหนดไว้ตามประเภท
      value: entry.value,
      title: title,  // ใช้ title ที่สร้างตามเงื่อนไข
      radius: 100,
      titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }).toList();
}
}