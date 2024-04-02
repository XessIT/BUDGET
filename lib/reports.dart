import 'package:flutter/material.dart';
import 'package:mybudget/monthlyReport.dart';
import 'package:mybudget/tripReport.dart';

import 'TripView.dart';
import 'dailyReport.dart';

//import 'monthlyReport.dart';

class Reports extends StatelessWidget {
  final String uid;
  const Reports({Key? key, required  this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Record",
          style: Theme.of(context).textTheme.titleMedium,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              children: [
                _buildClickableContainer('assets/Family Budget 2 (1).jpg',
                    'Monthly Budget', context, MonthlyReportPage(uid: uid)),
                const SizedBox(height: 10),
                _buildClickableContainer('assets/Trip Budget.jpg',
                    'Trip Budget', context, ViewDataPage()),
                const SizedBox(height: 10),
                _buildClickableContainer('assets/quick budget2.jpg',
                    'Personal Budget', context, PersonalBudgetPage()),
                const SizedBox(height: 10),
                _buildClickableContainer('assets/Purchase Budget 2 (2).jpg',
                    'Daily Expenses', context, DailyReportPage()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClickableContainer(
      String imagePath, String text, BuildContext context, Widget page) {
    return GestureDetector(
      onTap: () {
        // Navigate to a new page when the container is tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: _buildImageContainer(context, imagePath, text),
    );
  }

  Widget _buildImageContainer(
      BuildContext context, String imagePath, String text) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              fit: BoxFit
                  .fill, // Use BoxFit.fill to completely fill the container
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black54,
              ),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white)), // Set text color to white
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyBudgetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Budget Page'),
      ),
      body: Center(
        child: Text('This is the Monthly Budget Page!',
            style: TextStyle(color: Colors.white)), // Set text color to white
      ),
    );
  }
}

class TripBudgetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Budget Page'),
      ),
      body: Center(
        child: Text('This is the Trip Budget Page!',
            style: TextStyle(color: Colors.white)), // Set text color to white
      ),
    );
  }
}

class PersonalBudgetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Budget Page'),
      ),
      body: Center(
        child: Text('This is the Personal Budget Page!',
            style: TextStyle(color: Colors.white)), // Set text color to white
      ),
    );
  }
}

class DailyExpensesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses Page'),
      ),
      body: Center(
        child: Text('This is the Daily Expenses Page!',
            style: TextStyle(color: Colors.white)), // Set text color to white
      ),
    );
  }
}
