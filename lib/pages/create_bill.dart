import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:samarth_agencies/pages/create_pdf.dart';
import '../db service/db_service.dart';
import '../model/bill_model.dart';
import '../model/patient_model.dart';
import '../model/test_model.dart';
class TestDetails {
  int quantity;
  double currentPrice;

  TestDetails({required this.quantity, required this.currentPrice});
}
class CreateBill extends StatefulWidget {
  const CreateBill({Key? key}) : super(key: key);

  @override
  State<CreateBill> createState() => _CreateBillState();
}

class _CreateBillState extends State<CreateBill> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _testController = TextEditingController();
  final _paidController = TextEditingController();
  final _pendingController = TextEditingController();
  final _discountController = TextEditingController();
Map<Test, TestDetails> _selectedTests = {};

  late PatientDatabaseService _patientService;
  late TestDatabaseService _testService;
  //late BillDatabaseService _billService;

  Patient? _selectedPatient;
  // Map<Test, int> _selectedTests = {};
  double _totalAmount = 0;
  double _remainingAmount = 0;

  @override
  void initState() {
    super.initState();
    _patientService = PatientDatabaseService();
    _testService = TestDatabaseService();
    //_billService = BillDatabaseService();
    _paidController.addListener(_updateRemainingAmount);
    _pendingController.addListener(_updateRemainingAmount);
    _discountController.addListener(_updateRemainingAmount);
  }

  @override
  void dispose() {
    _patientController.dispose();
    _testController.dispose();
    _paidController.dispose();
    _pendingController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _updateRemainingAmount() {
    setState(() {
      double paid = double.tryParse(_paidController.text) ?? 0;
      double pending = double.tryParse(_pendingController.text) ?? 0;
      double discount = double.tryParse(_discountController.text) ?? 0;
      _remainingAmount = _totalAmount - paid - pending - discount;
    });
  }

  DateTime _selectedDate = DateTime.now(); // Initialize with current date

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Create Bill',style: TextStyle(),),
        // backgroundColor: Colors.blue[400],
    ),
    body: Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            SizedBox(height: 20),
            _buildPatientSelector(),
            SizedBox(height: 20),
            _buildTestSelector(),
            SizedBox(height: 20),
            _buildSelectedTestsCard(),
            SizedBox(height: 20),
            _buildAmountInputs(),
            SizedBox(height: 20),
            _buildTotalAmounts(),
            SizedBox(height: 30),
            _buildCreateBillButton(),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDateSelector() {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.blue[700]),
          SizedBox(width: 16),
          Text(
            "Select Date:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width:20),
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              "${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPatientSelector() {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Patient:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _selectedPatient == null
              ? _buildPatientAutocomplete()
              : _buildSelectedPatient(),
        ],
      ),
    ),
  );
}

Widget _buildTestSelector() {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Tests:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _buildTestAutocomplete(),
        ],
      ),
    ),
  );
}

Widget _buildSelectedTestsCard() {
  return Card(
    elevation: 2,
    child: Container(
      height: 350,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected Tests:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _selectedTests.isEmpty
                ? Center(child: Text("No Tests Selected"))
                : ListView.builder(
                    itemCount: _selectedTests.length,
                    itemBuilder: (context, index) {
                      final test = _selectedTests.keys.elementAt(index);
                      final details = _selectedTests[test]!;
                      return Card(
                        child: ListTile(
                          title: Text(test.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    prefixText: 'Rs ',
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: details.currentPrice.toStringAsFixed(2),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => _updateTestPrice(test, value),
                                ),
                              ),
                              SizedBox(width: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: Colors.red),
                                    onPressed: () => _updateTestQuantity(test, -1),
                                  ),
                                  Text('${details.quantity}', style: TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.green),
                                    onPressed: () => _updateTestQuantity(test, 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTest(test),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildAmountInputs() {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Details:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _paidController,
            decoration: InputDecoration(
              labelText: 'Paid Amount',
              prefixText: 'Rs ',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _discountController,
            decoration: InputDecoration(
              labelText: 'Discount',
              prefixText: 'Rs ',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    ),
  );
}

Widget _buildTotalAmounts() {
  return Card(
    elevation: 2,
    color: Colors.blue[50],
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Amount: Rs ${_totalAmount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Remaining Amount: Rs ${_remainingAmount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCreateBillButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _createBill,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Create Bill', style: TextStyle(fontSize: 18,color: Colors.white,fontWeight:  FontWeight.bold)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}

  Widget _buildPatientAutocomplete() {
    return StreamBuilder<QuerySnapshot<Patient>>(
      stream: _patientService.getPatients(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<Patient> patients = snapshot.data!.docs.map((doc) => doc.data()).toList();
    
        return Autocomplete<Patient>(
          displayStringForOption: (Patient option) => option.name,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<Patient>.empty();
            }
            return patients.where((Patient option) {
              return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (Patient selection) {
            setState(() {
              _selectedPatient = selection;
            });
          },
        );
      },
    );
  }

  Widget _buildSelectedPatient() {
    return Row(
      children: [
        Text(_selectedPatient!.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            setState(() {
              _selectedPatient = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTestAutocomplete() {
  return StreamBuilder<QuerySnapshot<Test>>(
    stream: _testService.getTests(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return CircularProgressIndicator();
      }

      List<Test> tests = snapshot.data!.docs.map((doc) => doc.data()).toList();

      return Autocomplete<Test>(
        displayStringForOption: (Test option) => option.name,
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<Test>.empty();
          }
          return tests.where((Test option) {
            return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (Test selection) {
          setState(() {
            if (_selectedTests.containsKey(selection)) {
              _selectedTests[selection]!.quantity += 1;
            } else {
              _selectedTests[selection] = TestDetails(quantity: 1, currentPrice: selection.price);
            }
            _updateTotalAmount();
          });
          _testController.clear();
        },
      );
    },
  );
}

  void _updateTestQuantity(Test test, int change) {
  setState(() {
    TestDetails details = _selectedTests[test]!;
    int newQuantity = details.quantity + change;
    if (newQuantity > 0) {
      details.quantity = newQuantity;
    } else {
      _selectedTests.remove(test);
    }
    _updateTotalAmount();
  });
}

  void _updateTestPrice(Test test, String newPrice) {
  setState(() {
    double price = double.tryParse(newPrice) ?? test.price;
    _selectedTests[test]!.currentPrice = price;
    _updateTotalAmount();
  });
}

void _removeTest(Test test) {
    setState(() {
      _selectedTests.remove(test);
      _updateTotalAmount();
    });
  }

// Update the _updateTotalAmount method:
void _updateTotalAmount() {
  _totalAmount = _selectedTests.entries.fold(0, (sum, entry) => 
    sum + (entry.value.currentPrice * entry.value.quantity));
  _updateRemainingAmount();
}

  


void _createBill() async {
  if (_formKey.currentState!.validate()) {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    if (_selectedTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one test')),
      );
      return;
    }

    // Calculate total amount

    try {
      double finaltotal = _totalAmount - (double.tryParse(_discountController.text) ?? 0);
      // Prepare a new Bill object with the fetched ID
      Bill newBill = Bill(
        id: '',
        documentId: '',
        patientName: _selectedPatient!.name,
        patientNumber: _selectedPatient!.phoneNumber,
        tests: _selectedTests.entries.map((entry) => TestItem(
          name: entry.key.name,
          price: entry.value.currentPrice,
          quantity: entry.value.quantity,
        )).toList(),
        totalAmount: finaltotal,
        subTotalAmount: _totalAmount,
        paidAmount: double.tryParse(_paidController.text) ?? 0,
        pendingAmount: _remainingAmount!=0 ? _remainingAmount : 0,
        discount: double.tryParse(_discountController.text) ?? 0,
        created: _selectedDate,
        updated: DateTime.now(),
      );

      
      // Add the new bill to Firestore
      await BillDatabaseService().addBill(newBill);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFPage(bill: newBill,),
        ),
      );

      // Navigate to a new page to display the created bill
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => DisplayBill(bill: newBill),
      //   ),
      // );
    } catch (e) {
      print('Error creating bill: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create bill')),
      );
    }
  }
}

    }