
import 'package:flutter/material.dart';

import '../../model/patient_model.dart';

class UpdatePatientDialog extends StatefulWidget {
  final Patient patient;
  final Function(Patient) onUpdate;

  const UpdatePatientDialog({Key? key, required this.patient, required this.onUpdate}) : super(key: key);

  @override
  _UpdatePatientDialogState createState() => _UpdatePatientDialogState();
}

class _UpdatePatientDialogState extends State<UpdatePatientDialog> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient.name);
    _ageController = TextEditingController(text: widget.patient.age.toString());
    _phoneNumberController = TextEditingController(text: widget.patient.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Patient'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedPatient = Patient(
              name: _nameController.text,
              age: int.tryParse(_ageController.text) ?? 0,
              phoneNumber: _phoneNumberController.text,
              timestamp: widget.patient.timestamp,
            );
            widget.onUpdate(updatedPatient);
            Navigator.of(context).pop();
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}