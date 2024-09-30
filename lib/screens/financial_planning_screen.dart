import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        scaffoldBackgroundColor: Colors.grey[900], // Background สีเข้ม
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black, // สี background ของ AppBar
          foregroundColor: Colors.white, // สีตัวอักษรของ AppBar
        ),
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('goals')
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      setState(() {
        _goals = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;

          if (data['savingsDetails'] != null && data['savingsDetails'] is List) {
            data['savingsDetails'] = (data['savingsDetails'] as List)
                .map((item) => {
                      ...Map<String, dynamic>.from(item),
                      'date': (item['date'] as Timestamp).toDate(),
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final Map<String, dynamic> newGoal = {
      'name': name,
      'amount': amount,
      'savingsDetails': [],
      'savings': 0.0,
      'userId': user.uid,
    };

    DocumentReference docRef = await FirebaseFirestore.instance.collection('goals').add(newGoal);

    setState(() {
      newGoal['id'] = docRef.id;
      _goals.add(newGoal);
    });
  }

  void _deleteGoal(int index) {
    final goalId = _goals[index]['id'];
    FirebaseFirestore.instance.collection('goals').doc(goalId).delete();

    setState(() {
      _goals.removeAt(index);
    });
  }

  void _addSavingsToGoal(int index, double amount) async {
    final goalId = _goals[index]['id'];
    final double currentSavings = _goals[index]['savings'] ?? 0.0;
    final double newSavings = currentSavings + amount;

    Map<String, dynamic> savingsDetail = {
      'amount': amount,
      'date': DateTime.now(),
    };

    await FirebaseFirestore.instance.collection('goals').doc(goalId).update({
      'savings': newSavings,
      'savingsDetails': FieldValue.arrayUnion([savingsDetail]),
    });

    setState(() {
      _goals[index]['savings'] = newSavings;
      _goals[index]['savingsDetails'].add(savingsDetail);
    });
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
                  progress = progress > 1.0 ? 1.0 : progress;
                  return Card(
                    elevation: 8,
                    color: Colors.grey[850],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        'เป้าหมาย: ฿${_goals[index]['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ชื่อเป้าหมาย: ${_goals[index]['name']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'ความก้าวหน้า: ${(progress * 100).toStringAsFixed(2)}%',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            color: Colors.greenAccent,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.greenAccent),
                            onPressed: () {
                              _showAddSavingsDialog(context, index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              _deleteGoal(index);
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _openAddGoalDialog(context),
              child: const Text('ตั้งเป้าหมาย', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
              backgroundColor: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              title: const Text(
                'เพิ่มเป้าหมายใหม่',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'ชื่อเป้าหมาย',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      newGoalName = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: goalAmountController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'จำนวนเงิน',
                      labelStyle: TextStyle(color: Colors.white),
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
                    Navigator.pop(context);
                  },
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton(
                  onPressed: () {
                    if (newGoalName.isNotEmpty && goalAmount > 0) {
                      _addNewGoal(newGoalName, goalAmount);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('เพิ่มเป้าหมาย', style: TextStyle(color: Colors.greenAccent)),
                ),
              ],
            );
          },
        );
      },
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
              backgroundColor: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              title: const Text('เพิ่มจำนวนเงินออม', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            amount = 100.0;
                            amountController.text = '100';
                          });
                        },
                        child: const Text('100', style: TextStyle(color: Colors.black)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            amount = 200.0;
                            amountController.text = '200';
                          });
                        },
                        child: const Text('200', style: TextStyle(color: Colors.black)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            amount = 300.0;
                            amountController.text = '300';
                          });
                        },
                        child: const Text('300', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'ระบุจำนวนเงิน',
                      labelStyle: TextStyle(color: Colors.white),
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
                    Navigator.pop(context);
                  },
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton(
                  onPressed: () {
                    if (amount > 0) {
                      _addSavingsToGoal(goalIndex, amount);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('บันทึก', style: TextStyle(color: Colors.greenAccent)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
