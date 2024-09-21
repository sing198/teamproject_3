import 'package:flutter/material.dart';

void main() => runApp(FinancialPlannerApp());

class FinancialPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FinancialPlannerScreen(),
    );
  }
}

class FinancialPlannerScreen extends StatefulWidget {
  @override
  _FinancialPlannerScreenState createState() => _FinancialPlannerScreenState();
}

class _FinancialPlannerScreenState extends State<FinancialPlannerScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _monthlyBudgetController = TextEditingController();
  double _totalSavings = 0.0;
  double _goalAmount = 0.0;
  double _monthlyBudget = 0.0;

  void _setFinancialGoal() {
    setState(() {
      _goalAmount = double.tryParse(_goalController.text) ?? 0.0;
    });
  }

  void _setMonthlyBudget() {
    setState(() {
      _monthlyBudget = double.tryParse(_monthlyBudgetController.text) ?? 0.0;
    });
  }

  void _addSavings(double amount) {
    setState(() {
      _totalSavings += amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Form for setting financial goal
            TextField(
              controller: _goalController,
              decoration: InputDecoration(
                labelText: 'เป้าหมายทางการเงิน (บาท)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _setFinancialGoal,
              child: Text('ตั้งเป้าหมาย'),
            ),
            
            SizedBox(height: 20),

            // Form for setting monthly budget
            TextField(
              controller: _monthlyBudgetController,
              decoration: InputDecoration(
                labelText: 'งบประมาณรายเดือน (บาท)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _setMonthlyBudget,
              child: Text('ตั้งงบประมาณรายเดือน'),
            ),

            SizedBox(height: 20),

            // Display current savings and goal
            Text(
              'ยอดเงินที่ออมได้: ฿${_totalSavings.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'เป้าหมาย: ฿${_goalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),

            // Progress bar for savings goal
            LinearProgressIndicator(
              value: _goalAmount > 0 ? _totalSavings / _goalAmount : 0,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
            ),
            SizedBox(height: 10),

            // Button to add savings
            ElevatedButton(
              onPressed: () {
                _addSavings(1000.0); // Example of adding savings
              },
              child: Text('เพิ่มการออม 1,000 บาท'),
            ),

            SizedBox(height: 20),

            // Monthly Budget Display
            Text(
              'งบประมาณรายเดือน: ฿${_monthlyBudget.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),

            // Remaining Budget
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // เพิ่มฟังก์ชันการคำนวณการใช้จ่ายจากงบประมาณ
                // สำหรับตัวอย่าง, ใช้งบประมาณ 500 บาท
                _monthlyBudget -= 500;
              },
              child: Text('ใช้จ่าย 500 บาท'),
            ),
            SizedBox(height: 10),
            Text(
              'งบประมาณคงเหลือ: ฿${_monthlyBudget.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
