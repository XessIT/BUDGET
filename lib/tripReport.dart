import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mybudget/DashBoard.dart';
import 'package:mybudget/reports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glass_kit/glass_kit.dart';

class TripBudgetReportPage extends StatefulWidget {
  @override
  _TripBudgetReportPageState createState() => _TripBudgetReportPageState();
}

class _TripBudgetReportPageState extends State<TripBudgetReportPage> {
  List<String> reportIds = [];

  @override
  void initState() {
    super.initState();
    _loadReportIds();
  }

  Future<void> _loadReportIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reportIds = prefs.getStringList('reportIds') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Trip Budget Reports",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.navigate_before,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Reports()));
          },
        ),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        elevation: 0.00,
        backgroundColor: Color(0xFF8155BA),
      ),
      body: ListView.builder(
        itemCount: reportIds.length,
        itemBuilder: (context, index) {
          return FutureBuilder<Map<String, dynamic>>(
            future: _getReportData(reportIds[index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return _buildReportCard(snapshot.data!, context);
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getReportData(String tripId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tripName = prefs.getString('$tripId:tripName');
    String? noOfPerson = prefs.getString('$tripId:noOfPerson');
    String? source = prefs.getString('$tripId:source');
    String? fromDate = prefs.getString('$tripId:fromDate');
    String? toDate = prefs.getString('$tripId:toDate');
    String? totalBudget = prefs.getString('$tripId:totalBudget');
    String? totalAmountPerson =
        prefs.getString('$tripId:totalAmountPerson') ?? "";
    List<String>? expensesList = prefs.getStringList('$tripId:expenses');
    List<String>? expensesListPerson = prefs.getStringList('$tripId:persons');
    List<String>? spentExpensesList =
    prefs.getStringList('$tripId:spentexpenses');
    double remaining = prefs.getDouble('$tripId:remaining') ?? 0.0;
    double debit = prefs.getDouble('$tripId:debit') ?? 0.0;

    // Prepare the data
    Map<String, dynamic> reportData = {
      'tripName': tripName,
      'noOfPerson': noOfPerson,
      'source': source,
      'fromDate': fromDate,
      'toDate': toDate,
      'totalBudget': totalBudget,
      'totalAmountPerson': totalAmountPerson,
      'expensesList': expensesList,
      'expensesListPerson': expensesListPerson,
      'spentExpenses': spentExpensesList,
      'remaining': remaining,
      'debit': debit
    };

    return reportData;
  }

  Widget _buildReportCard(Map<String, dynamic> data, BuildContext context) {
    String totalBudget = data['totalBudget'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedReportPage(reportData: data),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        child: GlassContainer(
          height: 100,
          width: double.infinity,
          gradient: LinearGradient(
            colors: [
              Color(0xFF8155BA),
              Colors.lightBlueAccent
            ], // Example gradient
          ),
          borderRadius: BorderRadius.circular(20),
          blur: 20,
          borderWidth: 0,
          borderColor: Colors.transparent,
          frostedOpacity: 0.1,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['tripName'] ?? '',
                          style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: 10),
                      Text(
                          'Total Budget : ₹${double.parse(totalBudget).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailedReportPage extends StatelessWidget {
  final Map<String, dynamic> reportData;

  DetailedReportPage({required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          reportData['tripName'] ?? '',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.navigate_before,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => DashBoard()));
          },
        ),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        elevation: 0.00,
        backgroundColor: Color(0xFF8155BA),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFF8155BA)),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildReportContent(context),
          ),
        ),
      ),
    );
  }
  int index = 0;

  Widget _buildReportContent(BuildContext context) {
    String? tripName = reportData['tripName'];
    String? source = reportData['source'];
    String? fromDate = reportData['fromDate'];
    String? toDate = reportData['toDate'];
    String? noOfPerson = reportData['noOfPerson'];
    List<String>? expensesList = reportData['expensesList'];
    List<String>? personsList = reportData['expensesListPerson'];
    final List<String>? spentExpensesList = reportData['spentExpenses'];
    String? totalAmountPerson =
    reportData['totalAmountPerson']; // Retrieve totalAmountPerson
    //double remaining = reportData['remaining'] ?? 0.0;
    // double debit = reportData['debit'] ?? 0.0;
    String? totalBudget = reportData['totalBudget'];

    // Calculate total spent amount
    double totalSpentAmount = 0.0;
    if (spentExpensesList != null) {
      for (String expense in spentExpensesList) {
        List<String> parts = expense.split(':');
        double amount = double.tryParse(parts[1]) ?? 0.0;
        totalSpentAmount += amount;
      }
    }

    // Calculate total expenses
    double totalExpenses = 0.0;
    if (expensesList != null) {
      for (String expense in expensesList) {
        List<String> parts = expense.split(':');
        double amount = double.tryParse(parts[1]) ?? 0.0;
        totalExpenses += amount;
      }
    }

    // Calculate total amount per person
    double totalAmountPerPerson = 0.0;
    if (personsList != null) {
      for (String person in personsList) {
        List<String> parts = person.split(':');
        double amount = double.tryParse(parts[1]) ?? 0.0;
        totalAmountPerPerson += amount;
      }
    }

    // Calculate remaining amount
    double remainingAmount =
        double.parse(totalAmountPerson!) - totalSpentAmount;

// Calculate debit amount
    double debitAmount = totalSpentAmount - double.parse(totalAmountPerson!);
    double perPersonSpend = totalSpentAmount / int.parse(noOfPerson!);

    // Calculate balance amount for each member
    List<Map<String, dynamic>> balanceAmounts = [];
    double totalReceivedAmount = double.parse(totalAmountPerson);
    int numberOfMembers = int.parse(noOfPerson);

    // Get the list of members and their received amounts
    List<Map<String, dynamic>> membersData = personsList!.map((person) {
      final parts = person.split(':');
      return {'name': parts[0], 'receivedAmount': double.parse(parts[1])};
    }).toList();

    // Calculate the balance amount for each member
    balanceAmounts = membersData.map((memberData) {
      double receivedAmount = memberData['receivedAmount'];
      double balanceAmount = perPersonSpend - receivedAmount;
      return {
        'name': memberData['name'],
        'receivedAmount': receivedAmount,
        'balanceAmount': balanceAmount,
      };
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Info",
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        _buildInfoSection(context, 'Location', source),
        _buildInfoSection(context, 'From Date', fromDate),
        _buildInfoSection(context, 'To Date', toDate),
        _buildInfoSection(context, 'Number of Members', noOfPerson),
        Divider(),
        //_buildExpensesList(context, expensesList, totalExpenses),
        _buildPersonsList(context, personsList, totalAmountPerson!),
        Divider(),
        _buildTotalSpentExpenses(context, spentExpensesList),
        _buildTotalSpentAmount(context, totalSpentAmount),
        if (spentExpensesList != null &&
            spentExpensesList.isNotEmpty) // Condition for showing remarks
          _buildremarks(context, spentExpensesList),
        Divider(),
        Text(
          'Amount Details',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Budget', style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text('₹${double.parse(totalBudget!).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Received Amount ',
                style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                totalAmountPerson.isNotEmpty
                    ? '₹${double.parse(totalAmountPerson!).toStringAsFixed(2)}'
                    : '₹0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Spent Amount ', style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                '₹${totalSpentAmount!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Spent Per Head', style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                '₹${perPersonSpend.toStringAsFixed(2)}', // Display perPersonSpend
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('No Of persons', style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text(noOfPerson.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 1,
            width: 70,
            color: Colors.grey, // Small line color
          ),
        ),

        Column(
          children: [
            if (remainingAmount > 0 && debitAmount <= 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Remaining Amount",
                      style: Theme.of(context).textTheme.bodySmall),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text("₹${remainingAmount.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            if (debitAmount > 0 && remainingAmount <= 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Debit Amount",
                      style: Theme.of(context).textTheme.bodySmall),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text("₹${debitAmount.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
          ],
        ),

        SizedBox(height: 10,),
        Divider(),
        Text(
          'Transaction Details',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          children: [
            const TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Name'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Received ₹'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Balance ₹'),
                  ),
                ),

              ],
            ),
            // Generate rows based on balance amounts
            for (var balanceData in balanceAmounts)
            // Inside the TableRow for balance amounts
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${++index}. ${balanceData['name']}'), // Increment index and display in the format "1. Name"
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(balanceData['receivedAmount'].toStringAsFixed(2),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        balanceData['balanceAmount'] < 0
                            ? '${balanceData['balanceAmount'].toStringAsFixed(2)} Return'
                            : '${balanceData['balanceAmount'].toStringAsFixed(2)} Get',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: balanceData['balanceAmount'] < 0 ? Colors.green : Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        )
        /* SizedBox(
          height: 15,
        ),
        if (debitAmount > 0 && remainingAmount <= 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Each member will pay the amount of Rs \n ₹${(debitAmount / int.parse(noOfPerson!)).toStringAsFixed(2)}/-",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        if (remainingAmount > 0 && debitAmount <= 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Each member will get a refund of Rs \n ₹${(remainingAmount / int.parse(noOfPerson!)).toStringAsFixed(2)}/-",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),*/
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall!),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value ?? 'N/A',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }


  Widget _buildPersonsList(
      BuildContext context,
      List<String>? personsList,
      String totalAmountPerson,
      ) {
    if (personsList == null || personsList.isEmpty) {
      return SizedBox.shrink();
    }

    // Convert totalAmountPerson to double and format it
    double totalAmount = double.tryParse(totalAmountPerson) ?? 0.0;
    String formattedTotalAmount = '₹${totalAmount.toStringAsFixed(2)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Received Amounts',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: personsList.map((person) {
            final parts = person.split(':');
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  parts[0],
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(width: 8),
                Text(
                  parts[1].isNotEmpty
                      ? '₹${double.parse(parts[1]).toStringAsFixed(2)}'
                      : "0.0",
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 1,
            width: 70,
            color: Colors.grey, // Small line color
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            formattedTotalAmount,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSpentAmount(BuildContext context, double totalSpentAmount) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 1,
            width: 70,
            color: Colors.grey, // Small line color
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            '₹${totalSpentAmount.toStringAsFixed(2)}',
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSpentExpenses(
      BuildContext context, List<String>? spentExpensesList) {
    if (spentExpensesList == null || spentExpensesList.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spent Expenses by Categories',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: spentExpensesList.map((expense) {
            final parts = expense.split(':');
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    parts[2],
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SizedBox(width: 30),
                Expanded(
                  flex: 2,
                  child: Text(
                    parts[0],
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${double.parse(parts[1]).toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildremarks(BuildContext context, List<String>? spentExpensesList) {
    if (spentExpensesList == null || spentExpensesList.isEmpty) {
      return SizedBox.shrink();
    }

    // Check if there are any remarks present in the list
    bool remarksPresent = spentExpensesList.any((expense) {
      final parts = expense.split(':');
      return parts.length > 3 && parts[3].isNotEmpty;
    });

    if (!remarksPresent) {
      return SizedBox.shrink();
    }

    List<Widget> remarkWidgets = spentExpensesList
        .map((expense) {
      final parts = expense.split(':');
      if (parts.length > 3 && parts[3].isNotEmpty) {
        return Column(
          children: [
            Text(
              parts[3].trim(),
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    })
        .where((widget) => widget != SizedBox.shrink())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          'Remarks',
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: remarkWidgets,
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
