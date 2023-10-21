import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final File? profileImage;

  const HomeScreen({Key? key, this.profileImage}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState(profileImage: profileImage);
}

class _HomeScreenState extends State<HomeScreen> {
  File? profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  _HomeScreenState({this.profileImage});

  String _age = '';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _dob = '';
  String _address = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _age = prefs.getInt('age')?.toString() ?? '';
      _firstName = prefs.getString('firstName') ?? '';
      _lastName = prefs.getString('lastName') ?? '';
      _email = prefs.getString('email') ?? '';
      _dob = prefs.getString('dob') ?? '';
      _address = prefs.getString('address') ?? '';
    });

    // Check if an updated profile image is passed as an argument
    if (widget.profileImage != null) {
      profileImage = widget.profileImage;
    } else {
      final imagePath = prefs.getString('profileImage');
      if (imagePath != null) {
        setState(() {
          profileImage = File(imagePath);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        profileImage = File(pickedFile.path);
        prefs.setString('profileImage', profileImage!.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _pickImage();
                },
                child: profileImage != null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(profileImage!),
                )
                    : const Icon(Icons.person, size: 100),
              ),
              const ListTile(
                title: Text('User Details', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('First Name:'),
                subtitle: Text(_firstName),
              ),
              ListTile(
                title: const Text('Last Name:'),
                subtitle: Text(_lastName),
              ),
              ListTile(
                title: const Text('Email:'),
                subtitle: Text(_email),
              ),
              ListTile(
                title: const Text('Date of Birth:'),
                subtitle: Text(_dob),
              ),
              ListTile(
                title: const Text('Address:'),
                subtitle: Text(_address),
              ),
              ListTile(
                title: const Text('Age:'),
                subtitle: Text(_age),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _logout(context);
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }
}
