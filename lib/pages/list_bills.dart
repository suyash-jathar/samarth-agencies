import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indian_currency_to_word/indian_currency_to_word.dart';
import 'package:samarth_agencies/pages/create_pdf.dart';
import '../db service/db_service.dart';
import '../model/bill_model.dart';

class ListBill extends StatefulWidget {
  const ListBill({Key? key}) : super(key: key);

  @override
  State<ListBill> createState() => _ListBillState();
}

class _ListBillState extends State<ListBill> {
  @override
  void initState() {
    super.initState();
  }

  final converter = AmountToWords();
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${date.day}-${months[date.month - 1]}-${date.year}";
  }


  void _updateBill(BuildContext context, Bill bill, String amountPaid) {
    double amount = double.tryParse(amountPaid) ?? 0;
    if (amount <= 0 || amount > bill.pendingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid amount entered'), backgroundColor: Colors.red),
      );
      return;
    }

    Bill updatedBill = Bill(
      id: bill.id,
      patientName: bill.patientName,
      patientNumber: bill.patientNumber,
      documentId: bill.documentId,
      tests: bill.tests,
      totalAmount: bill.totalAmount,
      subTotalAmount: bill.subTotalAmount,
      paidAmount: bill.paidAmount + amount,
      pendingAmount: bill.pendingAmount - amount,
      discount: bill.discount,
      created: bill.created,
      updated: DateTime.now(),
    );

    _billService.updateBill(bill.documentId, updatedBill).then((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bill updated successfully'), backgroundColor: Colors.green),
      );
    }).catchError((error) {
      Navigator.of(context).pop();
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update bill: $error'), backgroundColor: Colors.red),
      );
    });
  }

  void _showUpdateDialog(BuildContext context, Bill bill) {
    final TextEditingController _amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Bill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Pending Amount: Rs ${bill.pendingAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount Paid',
                  border: OutlineInputBorder(),
                  prefix: Text('Rs '),
                  // prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () => _updateBill(context, bill, _amountController.text),
            ),
          ],
        );
      },
    );
  }

  final BillDatabaseService _billService = BillDatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bills List'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by Patient Name or Bill ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = _searchController.text.trim();
                      });
                    },
                    icon: Icon(Icons.search),
                    label: Text('Search'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Bill>>(
              stream: _billService.getBills(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No bills found'));
                }

                List<Bill> bills = snapshot.data!.docs
                    .map((doc) => doc.data())
                    .where((bill) =>
                        _searchQuery.isEmpty ||
                        bill.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        bill.id.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                return ListView.builder(
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    Bill bill = bills[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          child: Text(bill.patientName[0].toUpperCase()),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        title: Text(bill.patientName, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Bill ID: ${bill.id}'),
                        children: [
                          ListTile(
                            title: Text('Created Date'),
                            trailing: Text(_formatDate(bill.created),style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),),
                          ),
                          ListTile(
                            title: Text('Total Amount'),
                            trailing: Text('Rs ${bill.totalAmount.toStringAsFixed(2)}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),),
                          ),
                          ListTile(
                            title: Text('Paid Amount'),
                            trailing: Text('Rs ${bill.paidAmount.toStringAsFixed(2)}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),),
                          ),
                          ListTile(
                            title: Text('Pending Amount'),
                            trailing: Text('Rs ${bill.pendingAmount.toStringAsFixed(2)}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(Icons.picture_as_pdf),
                                label: Text('Invoice'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFPage(bill: bill),
                                    ),
                                  );
                                },
                              ),
                              if (bill.pendingAmount != 0)
                                ElevatedButton.icon(
                                  icon: Icon(Icons.update),
                                  label: Text('Update'),
                                  onPressed: () => _showUpdateDialog(context, bill),
                                )
                              else
                                Chip(
                                  label: Text('No Pending'),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
