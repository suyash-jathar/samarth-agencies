import '../model/bill_model.dart';
import '../model/patient_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/test_model.dart';

class PatientDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Patient> _patientsRef;

  PatientDatabaseService() {
    _patientsRef = _firestore.collection('patients').withConverter<Patient>(
      fromFirestore: (snapshot, _) => Patient.fromJson(snapshot.data()!),
      toFirestore: (patient, _) => patient.toJson(),
    );
  }

  Stream<QuerySnapshot<Patient>> getPatients() {
    return _patientsRef.orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Patient>> getPatientsByAgeRange(int minAge, int maxAge) {
    return _patientsRef
        .where('age', isGreaterThanOrEqualTo: minAge)
        .where('age', isLessThanOrEqualTo: maxAge)
        .snapshots();
  }

  Future<void> addPatient(Patient patient) {
    return _patientsRef.add(patient);
  }

  Future<void> updatePatient(String id, Patient updatedPatient) {
    return _patientsRef.doc(id).update(updatedPatient.toJson());
  }

  Future<void> deletePatient(String id) {
    return _patientsRef.doc(id).delete();
  }
}

// test_database_service.dart
class TestDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Test> _testsRef;

  TestDatabaseService() {
    _testsRef = _firestore.collection('tests').withConverter<Test>(
      fromFirestore: (snapshot, _) => Test.fromJson(snapshot.id, snapshot.data()!),
      toFirestore: (test, _) => test.toJson(),
    );
  }

  Stream<QuerySnapshot<Test>> getTests() {
    return _testsRef.orderBy('name').snapshots();
  }

  Future<void> addTest(Test test) {
    return _testsRef.add(test);
  }

  Future<void> updateTest(Test updatedTest) {
    return _testsRef.doc(updatedTest.id).update(updatedTest.toJson());
  }

  Future<void> deleteTest(String id) {
    return _testsRef.doc(id).delete();
  }
}

class BillDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Bill> _billsRef;

  BillDatabaseService() {
    _billsRef = _firestore.collection('bills').withConverter<Bill>(
      fromFirestore: (snapshot, _) => Bill.fromMap(snapshot.data()!),
      toFirestore: (bill, _) => bill.toMap(),
    );
  }

  Stream<QuerySnapshot<Bill>> getBills() {
    return _billsRef.orderBy('id', descending: true).snapshots();
  }

  Future<String> getNextBillId() async {
    QuerySnapshot<Bill> snapshot =
        await _billsRef.orderBy('id', descending: true).limit(1).get();
    if (snapshot.size == 0) {
      return '2000';
    } else {
      String lastId = snapshot.docs[0].data().id;
      int lastNumber = int.parse(lastId);
      int nextNumber = lastNumber + 1;
      print("Print Nextnumber: $nextNumber");
      return nextNumber.toString().padLeft(4, '0');
    }
  }

  Future<void> addBill(Bill bill) async {
  String nextId = await getNextBillId();
  bill.id = nextId;
  DocumentReference docRef = await _billsRef.add(bill);
  bill.documentId = docRef.id;
  await docRef.update({'documentId': docRef.id});
}
  Future<void> updateBill(String id, Bill updatedBill) {
    return _billsRef.doc(id).update(updatedBill.toMap());
  }

  Future<void> deleteBill(String id) {
    return _billsRef.doc(id).delete();
  }
}
