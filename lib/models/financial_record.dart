class FinancialRecord {
  String id;
  String description;
  double amount;
  String type; // 'รายรับ', 'รายจ่าย', 'การออม'
  DateTime date; // เพิ่มฟิลด์ date เพื่อเก็บวันที่ของทรานแซคชัน

  FinancialRecord({
    this.id = '',
    required this.description,
    required this.amount,
    required this.type,
    required this.date, // ฟิลด์ date ต้องกำหนดค่าเมื่อสร้าง object
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(), // Convert date to ISO format
    };
  }
}
