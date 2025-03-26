import 'package:clinic_management/Drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyAmountGraph extends StatefulWidget {
  @override
  _DailyAmountGraphState createState() => _DailyAmountGraphState();
}

class _DailyAmountGraphState extends State<DailyAmountGraph> {
  Map<String, double> dailyAmounts = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<Map<String, double>> fetchDailyAmounts() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('patients').get();

    Map<String, double> dailyTotals = {};

    for (var doc in snapshot.docs) {
      String date = doc['date']; // Ensure this is in 'YYYY-MM-DD' format
      double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;

      if (dailyTotals.containsKey(date)) {
        dailyTotals[date] = dailyTotals[date]! + amount;
      } else {
        dailyTotals[date] = amount;
      }
    }
    return dailyTotals;
  }
  void loadData() async {
    Map<String, double> data = await fetchDailyAmounts();
    setState(() {
      dailyAmounts = data;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
      backgroundColor: Colors.blue.shade900,
      title: const Text(
        "Total Amount Graph",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
      drawer: DrawerPage(),
      body: dailyAmounts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            barGroups: dailyAmounts.entries.map((entry) {
              int index = dailyAmounts.keys.toList().indexOf(entry.key);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: Colors.blue,
                    width: 15,
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= dailyAmounts.keys.length) return Container();
                    String date = dailyAmounts.keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(date, style: TextStyle(fontSize: 10)),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}