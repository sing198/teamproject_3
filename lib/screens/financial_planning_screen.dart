import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FinancialPlannerApp());
}

class FinancialPlannerApp extends StatelessWidget {
  const FinancialPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Planner',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalSavings = 0.0;
  List<Map<String, dynamic>> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    // Load goals from Firebase and include document IDs
    FirebaseFirestore.instance.collection('goals').get().then((snapshot) {
      setState(() {
        _goals = snapshot.docs.map((doc) {
  var data = doc.data();
  data['id'] = doc.id; // Add document ID

  // Ensure savingsDetails is a List<Map<String, dynamic>> and convert Timestamp to DateTime
  if (data['savingsDetails'] != null && data['savingsDetails'] is List) {
    data['savingsDetails'] = (data['savingsDetails'] as List)
        .map((item) => {
              ...Map<String, dynamic>.from(item),
              'date': (item['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
            })
        .toList();
  } else {
    data['savingsDetails'] = [];
  }

  return data;
}).toList();


      });
    });
  }

  Future<void> _addNewGoal(String name, double amount) async {
    final Map<String, dynamic> newGoal = {
      'name': name,
      'amount': amount,
      'savingsDetails': [], // Initialize empty savings list
      'savings': 0.0, // Initialize total savings to 0
    };

    // Add new goal to Firestore and get document ID
    DocumentReference docRef = await FirebaseFirestore.instance.collection('goals').add(newGoal);

    // Add to local state with the document ID
    setState(() {
      newGoal['id'] = docRef.id;
      _goals.add(newGoal);
    });
  }

  void _deleteGoal(int index) {
    final goalId = _goals[index]['id'];

    // Delete goal from Firebase
    FirebaseFirestore.instance.collection('goals').doc(goalId).delete();

    setState(() {
      _goals.removeAt(index);
    });
  }

  void _addSavingsToGoal(int index, double amount) async {
    final goalId = _goals[index]['id'];
    final double currentSavings = _goals[index]['savings'] ?? 0.0;
    final double newSavings = currentSavings + amount;

    // Create a new savings detail entry
    Map<String, dynamic> savingsDetail = {
      'amount': amount,
      'date': DateTime.now(), // Store the current date
    };

    // Update Firestore with the new savings and savingsDetails
    await FirebaseFirestore.instance.collection('goals').doc(goalId).update({
      'savings': newSavings,
      'savingsDetails': FieldValue.arrayUnion([savingsDetail]), // Add to savingsDetails array
    });

    // Update local state
    setState(() {
      _goals[index]['savings'] = newSavings;
      _goals[index]['savingsDetails'].add(savingsDetail);
    });
  }

  void _showGoalDetails(BuildContext context, Map<String, dynamic> goal) {
    // Navigate to the GoalDetailsScreen with the goal details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailsScreen(
          goalName: goal['name'],
          goalAmount: goal['amount'],
          totalSavings: goal['savings'], // Pass the correct savings
          savingsDetails: goal['savingsDetails'], // Pass the correct savings details
        ),
      ),
    );
  }

  void _showAddSavingsDialog(BuildContext context, int goalIndex) {
    double amount = 0.0;
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              title: const Text('เพิ่มจำนวนเงินออม'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Default amount buttons (100, 200, 300)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            amount = 100.0;
                            amountController.text = '100';
                          });
                        },
                        child: const Text('100'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            amount = 200.0;
                            amountController.text = '200';
                          });
                        },
                        child: const Text('200'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            amount = 300.0;
                            amountController.text = '300';
                          });
                        },
                        child: const Text('300'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Input field for savings amount
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'ระบุจำนวนเงิน',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        amount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                  child: const Text('ยกเลิก'),
                ),
                TextButton(
                  onPressed: () {
                    if (amount > 0) {
                      _addSavingsToGoal(goalIndex, amount); // Add savings to the goal
                      Navigator.pop(context); // Close dialog
                    }
                  },
                  child: const Text('บันทึก'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openAddGoalDialog(BuildContext context) {
    String newGoalName = '';
    double goalAmount = 0.0;
    TextEditingController goalAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              title: const Text('เพิ่มเป้าหมายใหม่'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input for goal name
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'ชื่อเป้าหมาย',
                    ),
                    onChanged: (value) {
                      newGoalName = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Input for goal amount
                  TextField(
                    controller: goalAmountController,
                    decoration: const InputDecoration(
                      labelText: 'จำนวนเงิน',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        goalAmount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                  child: const Text('ยกเลิก'),
                ),
                TextButton(
                  onPressed: () {
                    if (newGoalName.isNotEmpty && goalAmount > 0) {
                      _addNewGoal(newGoalName, goalAmount); // Add new goal
                      Navigator.pop(context); // Close dialog
                    }
                  },
                  child: const Text('เพิ่มเป้าหมาย'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  double progress = (_goals[index]['savings'] ?? 0.0) / _goals[index]['amount'];
                  progress = progress > 1.0 ? 1.0 : progress; // Prevent over 100%
                  return Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text('เป้าหมาย: ฿${_goals[index]['amount'].toStringAsFixed(2)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ชื่อเป้าหมาย: ${_goals[index]['name']}'),
                          Text('ความก้าวหน้า: ${(progress * 100).toStringAsFixed(2)}%'),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            color: Colors.green,
                          ),
                        ],
                      ),
                      onTap: () => _showGoalDetails(context, _goals[index]), // Show goal details
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _showAddSavingsDialog(context, index); // Open dialog to add savings
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteGoal(index); // Delete goal
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => _openAddGoalDialog(context),
              child: const Text('ตั้งเป้าหมาย'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// Define GoalDetailsScreen to display the goal details
class GoalDetailsScreen extends StatelessWidget {
  final String goalName;
  final double goalAmount;
  final double totalSavings;
  final List<Map<String, dynamic>> savingsDetails;

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
                        final formattedDate = DateFormat('dd MMM yyyy').format(detail['date']);
                        return Card(
                          elevation: 2,
                          child: ListTile(
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
