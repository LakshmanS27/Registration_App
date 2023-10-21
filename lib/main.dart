import 'package:flutter/material.dart';
import 'package:regform/Screens/homescreen.dart';
import 'package:regform/Screens/loginscreen.dart';
import 'package:regform/Screens/registrationscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration and Login',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(), // route for the login screen
        '/home': (context) => const HomeScreen(),
        '/registration': (context) => RegistrationScreen(),
      },
    );
  }
}

class UserDetailsWidget extends StatelessWidget {
  const UserDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final prefs = snapshot.data;
        if (prefs == null) {
          return const Text('Error fetching data'); // Handle error
        }

        final firstName = prefs.getString('firstName') ?? '';
        final lastName = prefs.getString('lastName') ?? '';
        final email = prefs.getString('email') ?? '';
        final dob = prefs.getString('dob') ?? '';
        final address = prefs.getString('address') ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('First Name: $firstName'),
            Text('Last Name: $lastName'),
            Text('Email: $email'),
            Text('Date of Birth: $dob'),
            Text('Address: $address'),
          ],
        );
      },
    );
  }
}

