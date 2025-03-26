// import 'dart:ui';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AuthScreen extends StatefulWidget {
//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }
//
// class _AuthScreenState extends State<AuthScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLogin = true;
//   bool isLoading = false;
//   bool _isObscure = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           ImageFiltered(
//             imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
//             child: Image.asset(
//               'assets/background.jpg', // Add image to assets
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           /// **2. Login Card on Top**
//           Center(
//             child: Container(
//               padding: EdgeInsets.all(25),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.85), // Semi-transparent white
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               width: MediaQuery.of(context).size.width * 0.85,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     isLogin ? "Welcome Back!" : "Create Account",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 15),
//
//                   /// **Email Input**
//                   TextField(
//                     controller: emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       labelText: "Email",
//                       prefixIcon: Icon(Icons.email, color: Colors.blue),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//
//                   /// **Password Input**
//                   TextField(
//                     controller: passwordController,
//                     obscureText: _isObscure,
//                     decoration: InputDecoration(
//                       labelText: "Password",
//                       prefixIcon: Icon(Icons.lock, color: Colors.blue),
//                       suffixIcon: IconButton(
//                         icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
//                         onPressed: () {
//                           setState(() {
//                             _isObscure = !_isObscure;
//                           });
//                         },
//                       ),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                   SizedBox(height: 15),
//
//                   /// **Login/Signup Button**
//                   isLoading
//                       ? CircularProgressIndicator()
//                       : ElevatedButton(
//                     onPressed: () {}, // Implement auth function
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       backgroundColor: Colors.blue.shade900,
//                     ),
//                     child: Text(
//                       isLogin ? "Login" : "Sign Up",
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                     ),
//                   ),
//
//                   /// **Switch Between Login & Signup**
//                   SizedBox(height: 10),
//                   TextButton(
//                     onPressed: () => setState(() => isLogin = !isLogin),
//                     child: Text(
//                       isLogin ? "Don't have an account? Sign up" : "Already have an account? Login",
//                       style: TextStyle(color: Colors.blue.shade900, fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home.dart'; // Ensure you have FirstPage in Home.dart

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;
  bool _isObscure = true;
  String? userId;
  int patientCount = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
      _fetchPatientCount(storedUserId);
    }
  }

  Future<void> _fetchPatientCount(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('patients')
              .where(
                'userId',
                isEqualTo: userId,
              ) //  Fetch only the logged-in user's data
              .get();

      setState(() {
        patientCount = querySnapshot.docs.length;
      });
    } catch (e) {
      print("Error fetching patient count: $e");
    }
  }

  Future<void> handleAuth() async {
    setState(() => isLoading = true);
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        showSnackBar("Email and password cannot be empty.");
        setState(() => isLoading = false);
        return;
      }

      if (passwordController.text.length < 6) {
        showSnackBar("Password must be at least 6 characters.");
        setState(() => isLoading = false);
        return;
      }

      UserCredential userCredential;
      if (isLogin) {
        // Login
        userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // Signup
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        //  Store user data in Firestore on signup
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'email': emailController.text.trim(),
              'userId': userCredential.user!.uid, // Store user ID properly
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      //  Store user ID locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);
      setState(() => userId = userCredential.user!.uid);

      showSnackBar(isLogin ? "Login Successful!" : "Account Created!");

      //  Fetch patient count after login/signup
      _fetchPatientCount(userCredential.user!.uid);

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FirstPage()),
        );
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar("Error: ${e.message}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
            child: Image.asset(
              'assets/background.jpg', // Add image to assets
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLogin ? "Welcome Back!" : "Create Account",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: handleAuth,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blue.shade900,
                      ),
                      child: Text(
                        isLogin ? "Login" : "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin
                            ? "Don't have an account? Sign up"
                            : "Already have an account? Login",
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )

      // Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [Colors.blue.shade900, Colors.blue.shade300],
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      //   ),
        // assets/background.jpg
        // child:

      // ),
    );
  }
}
