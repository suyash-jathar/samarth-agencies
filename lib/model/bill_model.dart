class Bill {
  String id;
  String documentId;
  final String patientName;
  final String patientNumber; 
  final List<TestItem> tests;
  final double totalAmount;
  final double subTotalAmount;
  final double paidAmount;
  final double pendingAmount;
  final double discount;
  DateTime created;
  DateTime updated;

  Bill({
    required this.id,
    required this.patientName,
    required this.patientNumber,
    required this.documentId,
    required this.tests,
    required this.totalAmount,
    required this.subTotalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.discount,
    required this.created,
    required this.updated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'patientName': patientName,
      'patientNumber': patientNumber,
      'tests': tests.map((test) => test.toMap()).toList(),
      'totalAmount': totalAmount,
      'subTotalAmount': subTotalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'discount': discount,
      'created': created.toIso8601String(),  // Convert DateTime to ISO 8601 string
      'updated': updated.toIso8601String(),  // Convert DateTime to ISO 8601 string
    };
  }

  // factory Bill.fromMap(Map<String, dynamic> map) {
  //   print('Received map: $map');
  //   return Bill(
  //     id: map['id'] ?? '',  // Use an empty string as default if 'id' is null
  //     documentId: map['documentId'] ?? '',  // Use an empty string as default if 'id' is null
  //     patientName: map['patientName'],
  //     patientNumber: map['patientNumber'],
  //     tests: (map['tests'] as List).map((item) => TestItem.fromMap(item)).toList(),
  //     totalAmount: map['totalAmount'],
  //     subTotalAmount: map['subTotalAmount'],
  //     paidAmount: map['paidAmount'],
  //     pendingAmount: map['pendingAmount'],
  //     discount: map['discount'],
  //   );
  // }

  factory Bill.fromMap(Map<String, dynamic> map) {
      return Bill(
        id: map['id'] ?? '',
        documentId: map['documentId'] ?? '',
        patientName: map['patientName'] ?? '',
        patientNumber: map['patientNumber'] ?? '',
        tests: (map['tests'] as List?)?.map((item) => TestItem.fromMap(item)).toList() ?? [],
        totalAmount: (map['totalAmount'] ?? 0).toDouble(),
        subTotalAmount: (map['subTotalAmount'] ?? 0).toDouble(),
        paidAmount: (map['paidAmount'] ?? 0).toDouble(),
        pendingAmount: (map['pendingAmount'] ?? 0).toDouble(),
        discount: (map['discount'] ?? 0).toDouble(),
        created: DateTime.parse(map['created']),  // Parse ISO 8601 string to DateTime
        updated: DateTime.parse(map['updated']),  // Parse ISO 8601 string to DateTime
      );
    }
  }

class TestItem {
  final String name;
  final double price;
  final int quantity;

  TestItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory TestItem.fromMap(Map<String, dynamic> map) {
    return TestItem(
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}
