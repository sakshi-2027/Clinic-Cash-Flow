// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class SecondPage extends StatefulWidget {
//   const SecondPage({super.key});
//
//   @override
//   State<SecondPage> createState() => _SecondPageState();
// }
//
//
// // 6LlFeJhzNXDZMMUEstwW
//
// class _SecondPageState extends State<SecondPage> {
//   TextEditingController patientController = TextEditingController();
//   TextEditingController amountController = TextEditingController();
//   TextEditingController dateController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text("Record Page"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextFormField(
//               controller: patientController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Patient Name',
//               ),
//               onTap: () {},
//             ),
//             const SizedBox(height: 16), // Adds spacing between fields
//             TextFormField(
//               controller: amountController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Amount',
//               ),
//               onTap: () {},
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: dateController,
//               readOnly: true, // Prevent manual input
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Date',
//                 suffixIcon: Icon(Icons.calendar_today), // Calendar icon
//               ),
//               onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2101),
//                 );
//                 if (pickedDate != null) {
//                   String formattedDate =
//                       "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
//                   dateController.text = formattedDate;
//                 }
//               },
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {},
//               child: const Text("Submit"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Drawer.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  TextEditingController patientController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  Color customColor = Color(0xFF98B5BD);

  Future<void> addRecord() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current logged-in user

    if (user == null) {
      showSnackbar("User not logged in!", Colors.red);
      return;
    }

    if (patientController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        dateController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection("patients").add({
        "patientName": patientController.text,
        "amount": double.tryParse(amountController.text) ?? 0, // Store as double
        "date": dateController.text, // Storing date as string
        "userId": user.uid, // Store user ID
      });

      showSnackbar("Record Added!", Colors.green);
      Navigator.pop(context);
    } else {
      showSnackbar("Please fill all fields", Colors.red);
    }
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        title: const Text(
          "Add Record",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInputField(
                  "Patient Name",
                  Icons.person,
                  patientController,
                  false,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  "Amount",
                  Icons.attach_money,
                  amountController,
                  true,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    }
                  },
                  child: AbsorbPointer(
                    child: _buildInputField(
                      "Select Date",
                      Icons.calendar_today,
                      dateController,
                      false,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: addRecord,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isNumeric,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
