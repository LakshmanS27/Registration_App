import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

void main() {
  runApp(const MaterialApp(
    home: RegistrationScreen(),
  ));
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _dob = '';
  String _address = '';
  String _password = '';
  int _age = 0;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _clearFields();
            },
            icon: const Icon(Icons.clear, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _pickImage();
                },
                child: _profileImage != null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_profileImage!),
                )
                    : const ProfilePicture(
                  name: '',
                  radius: 40,
                  fontsize: 21,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _lastName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                onTap: () {
                  _selectDate(context);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dob = value!;
                  _calculateAge(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _address = value!;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitForm(context);
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final prefs = await SharedPreferences.getInstance();

      prefs.setString('firstName', _firstName);
      prefs.setString('lastName', _lastName);
      prefs.setString('email', _email);
      prefs.setString('dob', _dob);
      prefs.setString('address', _address);
      prefs.setString('password', _password);
      prefs.setInt('age', _age);

      final profileImagePath = _profileImage?.path;
      if (profileImagePath != null) {
        prefs.setString('profileImage', profileImagePath);
      }

      // Pass the image as an argument to the HomeScreen
      Navigator.pushReplacementNamed(context, '/home', arguments: _profileImage);
    }
  }

  void _clearFields() {
    _formKey.currentState!.reset();
    setState(() {
      _firstName = '';
      _lastName = '';
      _email = '';
      _dob = '';
      _address = '';
      _password = '';
      _age = 0;
      _dobController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _profileImage = null;
    });
  }

  void _calculateAge(String dob) {
    final dobDate = DateTime.parse(dob);
    final currentDate = DateTime.now();
    final age = currentDate.year - dobDate.year -
        ((currentDate.month > dobDate.month ||
            (currentDate.month == dobDate.month &&
                currentDate.day >= dobDate.day))
            ? 0
            : 1);
    _age = age;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }
}
