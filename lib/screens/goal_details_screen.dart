import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalDetailsScreen extends StatelessWidget {
  final String goalName;
  final double goalAmount;
  final double totalSavings;
  final List<Map<String, dynamic>> savingsDetails; // รายละเอียดการฝาก

  const GoalDetailsScreen({
    super.key,
    required this.goalName,
    required this.goalAmount,
    required this.totalSavings,
    required this.savingsDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียด: $goalName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เป้าหมาย: ฿${goalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'ยอดเงินที่ออมได้: ฿${totalSavings.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'รายละเอียดการฝากเงิน:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: savingsDetails.isNotEmpty
                  ? ListView.builder(
                      itemCount: savingsDetails.length,
                      itemBuilder: (context, index) {
                        final detail = savingsDetails[index];

                        // Format the date for better readability
                        final formattedDate = DateFormat('dd MMM yyyy').format(detail['date']);

                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.monetization_on, color: Colors.green),
                            title: Text(
                              '฿${detail['amount'].toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('วันที่: $formattedDate'),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'ยังไม่มีข้อมูลการฝากเงิน',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
