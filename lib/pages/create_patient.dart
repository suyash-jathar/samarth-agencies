import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../db service/db_service.dart';
import '../model/patient_model.dart';
import 'dialog_box/update_patient.dart';

class CreatePatient extends StatefulWidget {
  const CreatePatient({Key? key}) : super(key: key);

  @override
  State<CreatePatient> createState() => _CreatePatientState();
}

class _CreatePatientState extends State<CreatePatient> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isFirebaseInitialized = false;
  late PatientDatabaseService _patientService;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      _patientService = PatientDatabaseService();
      setState(() {
        _isFirebaseInitialized = true;
      });
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitPatient() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _patientService.addPatient(Patient(
          name: _nameController.text,
          age: _ageController.text.isNotEmpty? int.parse(_ageController.text): 0,
          phoneNumber: _phoneNumberController.text.isEmpty ? '' : _phoneNumberController.text,
          timestamp: DateTime.now(),
        ));
        _nameController.clear();
        _ageController.clear();
        _phoneNumberController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient added successfully'), backgroundColor: Colors.green),
        );
      } catch (e) {
        print('Error adding patient: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding patient: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Management'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isFirebaseInitialized
          ? _buildBody()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
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
                      children: [
                        Text(
                          'Add New Patient',
                          // style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Patient Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter patient name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.auto_mode_outlined),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _submitPatient,
                          icon: Icon(Icons.add),
                          label: Text('Add Patient'),
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
                child: PatientList(patientService: _patientService),
              ),
          ],
        );
      },
    );
  }
}

class PatientList extends StatefulWidget {
  final PatientDatabaseService patientService;

  const PatientList({Key? key, required this.patientService}) : super(key: key);

  @override
  _PatientListState createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updatePatient(String id, Patient patient) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdatePatientDialog(
          patient: patient,
          onUpdate: (updatedPatient) async {
            try {
              await widget.patientService.updatePatient(id, updatedPatient);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Patient updated successfully'), backgroundColor: Colors.green),
              );
            } catch (e) {
              print('Error updating patient: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating patient: $e'), backgroundColor: Colors.red),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _deletePatient(String id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this patient?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await widget.patientService.deletePatient(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient deleted successfully'), backgroundColor: Colors.green),
        );
      } catch (e) {
        print('Error deleting patient: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting patient: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
              'Patient List',
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
                      labelText: 'Search Patient',
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
              child: StreamBuilder<QuerySnapshot<Patient>>(
                stream: widget.patientService.getPatients(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No patients found'));
                  }

                  final patients = snapshot.data!.docs
                      .map((doc) => doc.data())
                      .where((patient) =>
                          patient.name.toLowerCase().contains(_searchQuery) ||
                          patient.phoneNumber.contains(_searchQuery))
                      .toList();

                  return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(patient.name[0].toUpperCase()),
                          ),
                          title: Text(patient.name),
                          subtitle: Text('Age: ${patient.age}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(patient.phoneNumber),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _updatePatient(snapshot.data!.docs[index].id, patient),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deletePatient(snapshot.data!.docs[index].id),
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
}
