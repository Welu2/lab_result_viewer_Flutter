import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/patient_profile.dart';
import '../provider/patient_provider.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final PatientProfile profile;
  final VoidCallback? onProfileUpdated;

  const EditProfileDialog({Key? key, required this.profile,
    this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String dob;
  late String email;
  late String gender;
  late String? relative;
  late double? weight;
  late double? height;
  late String? bloodType;
  late String? phoneNumber;

  bool isSaving = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    name = widget.profile.name;
    dob = widget.profile.dateOfBirth;
    email = widget.profile.email;
    gender = widget.profile.gender;
    relative = widget.profile.relative;
    weight = widget.profile.weight;
    height = widget.profile.height;
    bloodType = widget.profile.bloodType;
    phoneNumber = widget.profile.phoneNumber;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final updated = widget.profile.copyWith(
      name: name,
      dateOfBirth: dob,
      email: email,
      gender: gender,
      relative: relative,
      weight: weight,
      height: height,
      bloodType: bloodType,
      phoneNumber: phoneNumber,
    );

    setState(() {
      isSaving = true;
      errorMsg = null;
    });

    try {
      await ref.watch(updatePatientProfileProvider(UpdatePatientProfileParams(
        id: widget.profile.id,
        updatedProfile: updated,
      )).future);

      if (mounted) {
        widget.onProfileUpdated?.call(); 
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorMsg != null) ...[
                Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                onSaved: (v) => name = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: dob,
                decoration:
                    const InputDecoration(labelText: 'DOB (yyyy-mm-dd)'),
                validator: (v) {
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  return v != null && regex.hasMatch(v)
                      ? null
                      : 'Format: yyyy-mm-dd';
                },
                onSaved: (v) => dob = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Invalid email',
                onSaved: (v) => email = v!.trim(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: ['Male', 'Female']
                        .map((g) => g.toLowerCase())
                        .contains(gender.toLowerCase())
                    ? ['Male', 'Female'].firstWhere(
                        (g) => g.toLowerCase() == gender.toLowerCase(),
                      )
                    : null,
                decoration: const InputDecoration(labelText: 'Gender'),
                hint: const Text('Select Gender'),
                items: ['Male', 'Female']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => gender = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: relative,
                decoration: const InputDecoration(labelText: 'Relative'),
                onSaved: (v) => relative = v?.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                onSaved: (v) => phoneNumber = v?.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: weight?.toString(),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => weight = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: height?.toString(),
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => height = double.tryParse(v ?? ''),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : _save,
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
