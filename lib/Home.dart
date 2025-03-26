// import 'dart:io';
// import 'package:clinic_management/Drawer.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'AuthScreen.dart';
// import 'SecondPage.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'historypage.dart';
//
//
// class FirstPage extends StatefulWidget {
//   const FirstPage({super.key});
//
//   @override
//   State<FirstPage> createState() => _FirstPageState();
// }
//
// class _FirstPageState extends State<FirstPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   File? profileImage;
//   Color customColor = Color(0xFF98B5BD);
//   List<DocumentSnapshot> patients = [];
//
//
//
//   void _logout(BuildContext context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', false);
//     await _auth.signOut();
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => AuthScreen()),
//     );
//   }
//
//
//
//   void _deletePatient(int index) async {
//     try {
//       var snapshot = await _firestore
//           .collection("patients")
//           .where("userId", isEqualTo: _auth.currentUser?.uid)
//           .get();
//
//       if (snapshot.docs.isEmpty || index < 0 || index >= snapshot.docs.length) {
//         print("Error: Trying to delete from an empty list or invalid index");
//         return;
//       }
//
//       String docId = snapshot.docs[index].id; // Get the document ID
//
//       await _firestore.collection('patients').doc(docId).delete();
//
//       print("Patient deleted successfully");
//
//       // No need to manually remove from the list, Firestore will update the UI automatically.
//     } catch (e) {
//       print("Error deleting patient: $e");
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     String? userId = _auth.currentUser?.uid;
//     TextEditingController emailController = TextEditingController();
//     File? profileImage;
//
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Colors.blue.shade900,
//         title: const Text(
//           "Home Page",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => _logout(context),
//           ),
//         ],
//       ),
//       drawer: DrawerPage(),
//       body: Container(
//         constraints: BoxConstraints.expand(),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [customColor, Colors.blueGrey],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//
//         child:
//         userId == null
//             ? Center(child: CircularProgressIndicator()) // Show loading if user is not logged in
//             : StreamBuilder<QuerySnapshot>(
//           stream: _firestore
//               .collection("patients")
//               .where("userId", isEqualTo: userId)
//               .snapshots(),
//
//
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               );
//             }
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return const Center(
//                 child: Text(
//                   "No records found",
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               );
//             }
//             var patients = snapshot.data!.docs;
//             double totalAmount = patients.fold(0.0, (sum, patient) {
//               double amount =
//                   double.tryParse(patient["amount"].toString()) ?? 0.0;
//               return sum + amount;
//             });
//
//             return Column(
//               children: [
//                 // **Total Amount Display**
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 10,
//                     horizontal: 20,
//                   ),
//                   margin: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.green.shade700, Colors.green.shade400],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 8,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Total Amount: ₹${totalAmount.toStringAsFixed(2)}",
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           fontFamily: 'Raleway',
//                           letterSpacing: 1.2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: patients.length,
//                     itemBuilder: (context, index) {
//                       var patient = patients[index];
//                       String name = patient.data().toString().contains('patientName')
//                           ? patient["patientName"]
//                           : "Unknown";
//                       double amount = patient.data().toString().contains('amount')
//                           ? double.tryParse(patient["amount"].toString()) ?? 0.0
//                           : 0.0;
//                       String date = patient.data().toString().contains('date')
//                           ? patient["date"]
//                           : "N/A";
//
//                       return Dismissible(
//                         key: Key(patient.id), // Unique key for each item
//                         direction: DismissDirection.endToStart, // Allow swipe from right to left
//                         background: Container(
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           color: Colors.red,
//                           child: const Icon(Icons.delete, color: Colors.white, size: 30),
//                         ),
//                         confirmDismiss: (direction) async {
//                           return await showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: Text("Confirm Delete"),
//                                 content: Text("Are you sure you want to delete this patient?"),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.of(context).pop(false),
//                                     child: Text("Cancel"),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context).pop(true);
//                                     },
//                                     child: Text("Delete", style: TextStyle(color: Colors.red)),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                         onDismissed: (direction) {
//                           _deletePatient(index); // Call delete function
//                         },
//                         child: Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           elevation: 5,
//                           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
//                           child: ListTile(
//                             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             leading: CircleAvatar(
//                               backgroundColor: Colors.blue.shade700,
//                               child: const Icon(Icons.account_circle_sharp, color: Colors.white),
//                             ),
//                             title: Text(
//                               name,
//                               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text(
//                               "Date: $date",
//                               style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//                             ),
//                             trailing: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.shade600,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 "₹$amount",
//                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),

import 'package:clinic_management/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'SecondPage.dart';
import 'historypage.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Color customColor = Color(0xFF98B5BD);

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await _auth.signOut();

    Navigator.pushReplacementNamed(context, '/auth');
  }

  void _deletePatient(int index, String docId) async {
    try {
      await _firestore.collection('patients').doc(docId).delete();
      print("Patient deleted successfully");
    } catch (e) {
      print("Error deleting patient: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userId = _auth.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        title: const Text(
          "Home Page",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: DrawerPage(),
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [customColor, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            userId == null
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                  stream:
                      _firestore
                          .collection("patients")
                          .where("userId", isEqualTo: userId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No records found",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      );
                    }
                    var patients = snapshot.data!.docs;
                    double totalAmount = patients.fold(0.0, (sum, patient) {
                      double amount =
                          double.tryParse(patient["amount"].toString()) ?? 0.0;
                      return sum + amount;
                    });

                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.blueGrey],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Total Amount: ₹${totalAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AnimationLimiter(
                            child: ListView.builder(
                              itemCount: patients.length,
                              itemBuilder: (context, index) {
                                var patient = patients[index];
                                String name =
                                    patient["patientName"] ?? "Unknown";
                                double amount =
                                    double.tryParse(
                                      patient["amount"].toString(),
                                    ) ??
                                    0.0;
                                String date = patient["date"] ?? "N/A";
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: Duration(milliseconds: 500),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Dismissible(
                                        key: Key(patient.id),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          color: Colors.red,
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                        confirmDismiss: (direction) async {
                                          return await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                title: Text("Confirm Delete"),
                                                content: Text(
                                                  "Are you sure you want to delete this patient?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      _deletePatient(
                                                        index,
                                                        patient.id,
                                                      );
                                                      Navigator.of(
                                                        context,
                                                      ).pop(true);
                                                    },
                                                    child: Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          elevation: 5,
                                          margin: EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 5,
                                          ),
                                          child: InkWell(
                                            onTap: () {},
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Colors.blue.shade700,
                                                child: Icon(
                                                  Icons.account_circle_sharp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              title: Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                "Date: $date",
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              trailing: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade600,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  "₹$amount",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),

      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22, color: Colors.white),
        backgroundColor: Colors.blue.shade900,
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add, color: Colors.white),
            label: "Add Record",
            backgroundColor: Colors.blue.shade700, // Button color
            labelBackgroundColor:
                Colors.blue.shade700, // Matching label background color
            labelStyle: const TextStyle(
              color: Colors.white,
            ), // Ensure label text is visible
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondPage(),
                ), // Navigate to Add Record page
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.history, color: Colors.white),
            label: "History",
            backgroundColor: Colors.green.shade700, // Button color
            labelBackgroundColor:
                Colors.green.shade700, // Matching label background color
            labelStyle: const TextStyle(
              color: Colors.white,
            ), // Ensure label text is visible
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(),
                ), // Navigate to History page
              );
            },
          ),
        ],
      ),
    );
  }
}

// Expanded(
//   child: ListView.builder(
//     itemCount: patients.length,
//     itemBuilder: (context, index) {
//       var patient = patients[index];
//       String name = patient.data().toString().contains('patientName')
//           ? patient["patientName"]
//           : "Unknown";
//       double amount = patient.data().toString().contains('amount')
//           ? double.tryParse(patient["amount"].toString()) ?? 0.0
//           : 0.0;
//       String date = patient.data().toString().contains('date')
//           ? patient["date"]
//           : "N/A";
//       return Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         elevation: 5,
//         margin: const EdgeInsets.symmetric(
//           vertical: 8,
//           horizontal: 5,
//         ),
//         child: ListTile(
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 8,
//           ),
//           leading: CircleAvatar(
//             backgroundColor: Colors.blue.shade700,
//             child: const Icon(
//               Icons.account_circle_sharp,
//               color: Colors.white,
//             ),
//           ),
//           title: Text(
//             name,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           subtitle: Text(
//             "Date: $date",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade600,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   "₹$amount",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8), // Space between amount and delete icon
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.red),
//                 onPressed: () {
//                   _deletePatient(index); // Function to delete the patient
//                 },
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   ),
// ),
