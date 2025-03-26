import 'package:clinic_management/Drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Stream<QuerySnapshot> fetchRecords() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection("patients")
        .where("userId", isEqualTo: user.uid)
        .orderBy("date", descending: true) // Sorting by date
        .snapshots();
  }

  Future<void> deleteRecordsByDate(String date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection("patients")
        .where("userId", isEqualTo: user.uid)
        .where("date", isEqualTo: date)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color customColor = Color(0xFF98B5BD);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("History Records", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
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
        child: StreamBuilder<QuerySnapshot>(
          stream: fetchRecords(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<QueryDocumentSnapshot> records = snapshot.data!.docs;

            // Grouping data by date
            Map<String, List<QueryDocumentSnapshot>> groupedRecords = {};
            for (var record in records) {
              String date = record["date"];
              if (groupedRecords.containsKey(date)) {
                groupedRecords[date]!.add(record);
              } else {
                groupedRecords[date] = [record];
              }
            }

            return ListView(
              padding: const EdgeInsets.all(10),
              children: groupedRecords.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for Date & Delete Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Date Container
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade800,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.key, // Date
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Delete Button Container
                       IconButton(
                            icon: Icon(Icons.delete,  color: Colors.red),
                            onPressed: () async {
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Delete Records"),
                                  content: Text("Are you sure you want to delete all records for ${entry.key}?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ) ?? false;

                              if (confirmDelete) {
                                await deleteRecordsByDate(entry.key);
                              }
                            },
                          ),

                      ],
                    ),

                    // List of records for this date
                    ...entry.value.map((record) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(record["patientName"]),
                          subtitle: Text("Amount: ₹${record["amount"]}"),
                          trailing: Icon(
                            Icons.medical_services,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
