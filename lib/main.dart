import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:samarth_agencies/home_page.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb)
  {
    await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCXgg5Ag7VAE4A2y0M2OF_KCffJrOZGlLc",
      authDomain: "samarth-agencies.firebaseapp.com",
      projectId: "samarth-agencies",
      storageBucket: "samarth-agencies.appspot.com",
      messagingSenderId: "440390071098",
      appId: "1:440390071098:web:6948b47432911ea3d49603",
      measurementId: "G-MP1YKQH6Z1"
    ),
  );
  }
  else
  {
    await Firebase.initializeApp();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
  //   List<TestItem> tests = [
  //  TestItem(name: 'name', price: 40,quantity: 1),
  //  TestItem(name: 'name', price: 45,quantity: 1),
  //   ];
    return MaterialApp(
      title: 'Samarth Agencies',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home:  HomePage(title:'Home Page'),
      home:  HomePage(title: 'Samarth Agencies')
      // home:  PDFPage(bill: Bill(id: '1',documentId: '',subTotalAmount: 450, patientName: 'Yash', patientNumber: '8645710216', tests: tests, totalAmount: 450, paidAmount: 0, pendingAmount: 0, discount: 0, created: DateTime.now(), updated: DateTime.now()),)
    );
  }
}
