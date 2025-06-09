import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/create_profile_request.dart';
import '../provider/patient_provider.dart';

class RegisterCreateProfileDialog extends ConsumerStatefulWidget {
  final VoidCallback? onProfileCreated;

  const RegisterCreateProfileDialog({Key? key, this.onProfileCreated})
      : super(key: key);

  @override
  _RegisterCreateProfileDialogState createState() =>
      _RegisterCreateProfileDialogState();
}

class _RegisterCreateProfileDialogState
    extends ConsumerState<RegisterCreateProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String name = '';
  String dob = '';
  String gender = 'Male';

  String? relative;
  String? phoneNumber;
  String? bloodType;
  double? weight;
  double? height;

  bool isLoading = false;
  String? error;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final profileReq = CreateProfileRequest(
      name: name,
      dateOfBirth: dob,
      email: email,
      gender: gender,
      role: "user",
      password: password,
      relative: relative,
      phoneNumber: phoneNumber,
      bloodType: bloodType,
      weight: weight,
      height: height,
    );

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await ref.read(createUserAndProfileProvider(profileReq).future);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration & profile created')),
        );
        widget.onProfileCreated?.call();
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register & Create Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (error != null) ...[
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
              ],
              _buildTextField(
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Enter valid email',
                onSaved: (v) => email = v!.trim(),
              ),
              _buildTextField(
                label: 'Password',
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Min 6 chars',
                onSaved: (v) => password = v!.trim(),
              ),
              _buildTextField(
                label: 'Name',
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                onSaved: (v) => name = v!.trim(),
              ),
              _buildTextField(
                label: 'DOB (yyyy-mm-dd)',
                validator: (v) {
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  return v != null && regex.hasMatch(v)
                      ? null
                      : 'Format: yyyy-mm-dd';
                },
                onSaved: (v) => dob = v!.trim(),
              ),
              _buildTextField(
                label: 'Relative (optional)',
                onSaved: (v) => relative = v?.trim(),
              ),
              _buildTextField(
                label: 'Phone Number (optional)',
                keyboardType: TextInputType.phone,
                onSaved: (v) => phoneNumber = v?.trim(),
              ),
              _buildTextField(
                label: 'Blood Type (optional)',
                onSaved: (v) => bloodType = v?.trim(),
              ),
              _buildTextField(
                label: 'Weight (kg)',
                keyboardType: TextInputType.number,
                onSaved: (v) =>
                    weight = double.tryParse(v!.trim().replaceAll(',', '.')),
              ),
              _buildTextField(
                label: 'Height (cm)',
                keyboardType: TextInputType.number,
                onSaved: (v) =>
                    height = double.tryParse(v!.trim().replaceAll(',', '.')),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => gender = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    required void Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
