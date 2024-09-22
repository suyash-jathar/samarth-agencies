// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../db service/db_service.dart';
// import '../model/bill_model.dart';

// class LiveDashboard extends StatefulWidget {
//   const LiveDashboard({Key? key}) : super(key: key);

//   @override
//   State<LiveDashboard> createState() => _LiveDashboardState();
// }

// class _LiveDashboardState extends State<LiveDashboard> {
//   final BillDatabaseService _billService = BillDatabaseService();
//   final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Live Dashboard'),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<QuerySnapshot<Bill>>(
//         stream: _billService.getBills(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final bills = snapshot.data?.docs.map((doc) => doc.data()).toList() ?? [];

//           return SingleChildScrollView(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSummaryCards(bills),
//                 SizedBox(height: 24),
//                 _buildRevenueChart(bills),
//                 SizedBox(height: 24),
//                 _buildPendingAmountChart(bills),
//                 SizedBox(height: 24),
//                 _buildTopTestsChart(bills),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSummaryCards(List<Bill> bills) {
//     final totalRevenue = bills.fold(0.0, (sum, bill) => sum + bill.totalAmount);
//     final totalPending = bills.fold(0.0, (sum, bill) => sum + bill.pendingAmount);
//     final totalBills = bills.length;

//     return Row(
//       children: [
//         _buildSummaryCard('Total Revenue', currencyFormatter.format(totalRevenue), Colors.green),
//         SizedBox(width: 16),
//         _buildSummaryCard('Pending Amount', currencyFormatter.format(totalPending), Colors.orange),
//         SizedBox(width: 16),
//         _buildSummaryCard('Total Bills', totalBills.toString(), Colors.blue),
//       ],
//     );
//   }

//   Widget _buildSummaryCard(String title, String value, Color color) {
//     return Expanded(
//       child: Card(
//         elevation: 4,
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRevenueChart(List<Bill> bills) {
//     final dailyRevenue = _calculateDailyRevenue(bills);

//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Daily Revenue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 16),
//             Container(
//               height: 200,
//               child: LineChart(
//                 LineChartData(
//                   gridData: FlGridData(show: false),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: dailyRevenue.asMap().entries.map((entry) {
//                         return FlSpot(entry.key.toDouble(), entry.value);
//                       }).toList(),
//                       isCurved: true,
//                       color: Colors.blue,
//                       barWidth: 3,
//                       dotData: FlDotData(show: false),
//                       belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPendingAmountChart(List<Bill> bills) {
//     final pendingAmount = bills.fold(0.0, (sum, bill) => sum + bill.pendingAmount);
//     final paidAmount = bills.fold(0.0, (sum, bill) => sum + bill.paidAmount);

//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Paid vs Pending Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 16),
//             Container(
//               height: 200,
//               child: PieChart(
//                 PieChartData(
//                   sections: [
//                     PieChartSectionData(
//                       color: Colors.green,
//                       value: paidAmount,
//                       title: 'Paid',
//                       radius: 100,
//                       titleStyle: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                     PieChartSectionData(
//                       color: Colors.red,
//                       value: pendingAmount,
//                       title: 'Pending',
//                       radius: 100,
//                       titleStyle: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ],
//                   sectionsSpace: 0,
//                   centerSpaceRadius: 40,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTopTestsChart(List<Bill> bills) {
//     final testCounts = _calculateTopTests(bills);

//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Top 5 Tests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 16),
//             Container(
//               height: 200,
//               child: BarChart(
//                 BarChartData(
//                   alignment: BarChartAlignment.spaceAround,
//                   maxY: testCounts.values.reduce((a, b) => a > b ? a : b).toDouble(),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           if (value.toInt() >= 0 && value.toInt() < testCounts.keys.length) {
//                             return Text(
//                               testCounts.keys.elementAt(value.toInt()),
//                               style: TextStyle(fontSize: 10),
//                             );
//                           }
//                           return Text('');
//                         },
//                       ),
//                     ),
//                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   barGroups: testCounts.entries.map((entry) {
//                     return BarChartGroupData(
//                       x: testCounts.keys.toList().indexOf(entry.key),
//                       barRods: [
//                         BarChartRodData(
//                           toY: entry.value.toDouble(),
//                           color: Colors.blue,
//                           width: 16,
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<double> _calculateDailyRevenue(List<Bill> bills) {
//     final dailyRevenue = <DateTime, double>{};
//     final now = DateTime.now();
//     final sevenDaysAgo = now.subtract(Duration(days: 7));

//     for (var i = 0; i < 7; i++) {
//       final day = sevenDaysAgo.add(Duration(days: i));
//       dailyRevenue[day] = 0;
//     }

//     for (var bill in bills) {
//       final billDate = bill.created.toLocal();
//       if (billDate.isAfter(sevenDaysAgo) && billDate.isBefore(now)) {
//         final day = DateTime(billDate.year, billDate.month, billDate.day);
//         dailyRevenue[day] = (dailyRevenue[day] ?? 0) + bill.totalAmount;
//       }
//     }

//     return dailyRevenue.values.toList();
//   }

//   Map<String, int> _calculateTopTests(List<Bill> bills) {
//     final testCounts = <String, int>{};

//     for (var bill in bills) {
//       for (var test in bill.tests) {
//         testCounts[test.name] = (testCounts[test.name] ?? 0) + test.quantity;
//       }
//     }

//     final sortedTests = testCounts.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     return Map.fromEntries(sortedTests.take(5));
//   }
// }