import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/bill_model.dart';

class BillDBService {
  final CollectionReference _billsCollection = FirebaseFirestore.instance.collection('bills');

  Future<String> createBill(Bill bill) async {
    DocumentReference docRef = await _billsCollection.add(bill.toMap());
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  Stream<List<Bill>> getBills() {
  return _billsCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Bill.fromMap(doc.data() as Map<String, dynamic>)..id = doc.id;
    }).toList();
  });
}

  Future<void> updateBill(Bill bill) async {
    await _billsCollection.doc(bill.id).update(bill.toMap());
  }

  Future<void> deleteBill(String id) async {
    await _billsCollection.doc(id).delete();
  }
}