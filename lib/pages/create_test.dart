import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:samarth_agencies/db%20service/db_service.dart';

import '../model/test_model.dart';


class CreateTests extends StatefulWidget {
  const CreateTests({Key? key}) : super(key: key);

  @override
  State<CreateTests> createState() => _CreateTestsState();
}

class _CreateTestsState extends State<CreateTests> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  late TestDatabaseService _testService;

  @override
  void initState() {
    super.initState();
    _testService = TestDatabaseService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitTest() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _testService.addTest(Test(
          id: '',
          name: _nameController.text,
          price: double.parse(_priceController.text),
        ));
        _nameController.clear();
        _priceController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test added successfully'), backgroundColor: Colors.green),
        );
      } catch (e) {
        print('Error adding test: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding test: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tests'),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  margin: EdgeInsets.all(16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Add New Test',
                            // style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Test Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.medical_services),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter test name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                              prefixText: 'Rs '
                              // prefixIcon: Icon(Icons.money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _submitTest,
                            icon: Icon(Icons.add),
                            label: Text('Add Test'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (constraints.maxWidth > 600)
                Expanded(
                  flex: 2,
                  child: TestList(testService: _testService),
                ),
            ],
          );
        },
      ),
    );
  }
}

class TestList extends StatefulWidget {
  final TestDatabaseService testService;

  const TestList({Key? key, required this.testService}) : super(key: key);

  @override
  _TestListState createState() => _TestListState();
}

class _TestListState extends State<TestList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test List',
              // style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Test',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text.toLowerCase();
                    });
                  },
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Test>>(
                stream: widget.testService.getTests(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No tests found'));
                  }

                  final tests = snapshot.data!.docs
                      .map((doc) => doc.data())
                      .where((test) =>
                          test.name.toLowerCase().contains(_searchQuery) ||
                          test.price.toString().contains(_searchQuery))
                      .toList();

                  return ListView.builder(
                    itemCount: tests.length,
                    itemBuilder: (context, index) {
                      final test = tests[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(test.name[0].toUpperCase()),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          title: Text(test.name),
                          subtitle: Text('Rs ${test.price.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditDialog(context, test),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmation(context, test),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Test test) {
    final nameController = TextEditingController(text: test.name);
    final priceController = TextEditingController(text: test.price.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Test'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Test Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                _updateTest(
                  context,
                  test.id,
                  nameController.text,
                  double.tryParse(priceController.text) ?? test.price,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Test test) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Test'),
          content: Text('Are you sure you want to delete ${test.name}?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.testService.deleteTest(test.id).then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Test deleted successfully'), backgroundColor: Colors.green),
                  );
                }).catchError((error) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting test: $error'), backgroundColor: Colors.red),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _updateTest(BuildContext context, String id, String name, double price) {
    widget.testService.updateTest(Test(id: id, name: name, price: price)).then((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test updated successfully'), backgroundColor: Colors.green),
      );
    }).catchError((error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating test: $error'), backgroundColor: Colors.red),
      );
    });
  }
}