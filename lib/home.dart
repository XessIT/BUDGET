import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:mybudget/sample.dart';

import 'DashBoard.dart';




class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFff0f63),
        title: const Text(
          'My Budget',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> DashBoard()));
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFFFF3E0),
      bottomNavigationBar: BottomBarBubble(
        color:  Color(0xFFff0f63),




        items: [
          BottomBarItem(
            iconData: Icons.home,
            label: 'Home',
          ),
          BottomBarItem(
            iconData: Icons.signal_cellular_alt_sharp,
            label: 'Tracking',
          ),
          BottomBarItem(
            iconData: Icons.add,
            label: 'Spent',
          ),
          BottomBarItem(
            iconData: Icons.note_add,
            label: 'Records',
          ),
          BottomBarItem(
            iconData: Icons.money,
            label: 'Income',
          ),
        ],
        onSelect: (index) {
          // implement your select function here
        },
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            buildBudgetCard(context, "Monthly Budget"),
            buildBudgetCard(context, "Trip Budget"),
            buildBudgetCard(context, "Personal Budget"),
            buildBudgetCard(context, "Daily Expenses"),
          ],
        ),
      ),
    );
  }

  Widget buildBudgetCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        // Navigate to another page
        /*
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BudgetDetailPage(title)),
        );
        */
      },
      child: Card(
        elevation: 4, // Add elevation for a raised appearance
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Round the corners
        ),
        margin: EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              //F73D93
              //        color:  Color(0xFFff0f63),
              colors: [Colors.white, Colors.blueAccent], // Add a gradient background
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.attach_money, // Add an icon for visual appeal
                size: 40.0,
                color: Colors.white,
              ),
              SizedBox(height: 10), // Add spacing between icon and title
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

