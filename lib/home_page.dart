import 'package:flutter/material.dart';
import 'package:samarth_agencies/pages/create_patient.dart';
import 'package:samarth_agencies/pages/create_test.dart';
import 'package:samarth_agencies/pages/create_bill.dart';
import 'package:samarth_agencies/pages/list_bills.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'S S Pathology Invoice',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Create Bill'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateBill()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.supervisor_account),
              title: Text('Create Patient'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePatient()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.file_copy_rounded),
              title: Text('Tests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTests()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('List of Bills'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListBill()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                // Replace with actual Dashboard widget when available
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Center(child: Text("Coming Soon -> Live Dashboard")),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text("Welcome to S S Pathology Invoice")),
    );
  }
}
