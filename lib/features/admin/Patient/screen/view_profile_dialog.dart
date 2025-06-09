import 'package:flutter/material.dart';
import '../model/patient_profile.dart';

class ViewProfileDialog extends StatelessWidget {
  final PatientProfile profile;

  const ViewProfileDialog({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Patient Profile'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text('Name: ${profile.name}'),
            Text('ID: ${profile.id}'),
             Text("PatientId: ${profile.patientId}"),
            Text('DOB: ${profile.dateOfBirth}'),
            Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 8),
                Text(profile.email),
              ],
            ),
            Text("Relative: ${profile.relative}"),
             Text("Gender: ${profile.gender}"),
              Text("Weight: ${profile.weight}"),
             Text("Height: ${profile.height}"),
             Text("BloodType: ${profile.bloodType}"),
            Text("PhoneNumber: ${profile.phoneNumber}"),
            
             
             
            
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
