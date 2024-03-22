import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'DashBoard.dart';
import 'MonthlyBudget2.dart';

class Balance extends StatefulWidget {
  const Balance({Key? key}) : super(key: key);

  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> trips = [];
  final TextEditingController monthlyincome = TextEditingController();
  final TextEditingController monthlyincomeType = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllMonthEndRemaining();
  }


  Future<void> fetchAllMonthEndRemaining() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    List<Map<String, dynamic>> fetchedTrips = [];
    double totalRemainingValue = 0; // Initialize total to 0

    for (String key in keys) {
      if (key.endsWith(':monthendRemaining')) {
        String monthId = key.split(':')[0];
        String? remainingValue = prefs.getString(key);
        String? fromDate = prefs.getString('$monthId:fromDate');
        String? toDate = prefs.getString('$monthId:toDate');
        if (remainingValue != null && fromDate != null && toDate != null) {
          // Extract numeric part of the string using regular expression
          RegExp regExp = RegExp(r'(\d+(\.\d+)?)');
          Iterable<Match> matches = regExp.allMatches(remainingValue);
          double value = double.parse(matches.first.group(0)!);
          fetchedTrips.add({
            'monthId': monthId,
            'remainingValue': remainingValue,
            'fromDate': fromDate,
            'toDate': toDate,
          });
          // Add the remaining value to the total
          totalRemainingValue += value;
        }
      }
    }

    // Update state with fetched data
    setState(() {
      trips = fetchedTrips;
      print('Total Remaining Value: ₹${totalRemainingValue.toStringAsFixed(2)}'); // Print the total remaining value
    });
  }



  /* Future<void> fetchAllMonthEndRemaining() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    List<Map<String, dynamic>> fetchedTrips = [];

    for (String key in keys) {
      if (key.endsWith(':monthendRemaining')) {
        String monthId = key.split(':')[0];
        String? remainingValue = prefs.getString(key);
        String? fromDate = prefs.getString('$monthId:fromDate');
        String? toDate = prefs.getString('$monthId:toDate');
        if (remainingValue != null && fromDate != null && toDate != null) {
          fetchedTrips.add({
            'monthId': monthId,
            'remainingValue': remainingValue,
            'fromDate': fromDate,
            'toDate': toDate,
          });
        }
      }
    }

    // Update state with fetched data
    setState(() {
      trips = fetchedTrips;
    });
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Text(
            "Balance ",
            //style: Theme.of(context).textTheme.display1,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DashBoard()));
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
      ),
      body: Form(
        key: _formKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 5),
                // Display fetched data
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Remaining Value for monthId ${trips[index]['monthId']}: ${trips[index]['remainingValue']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From: ${trips[index]['fromDate']}'),
                          Text('To: ${trips[index]['toDate']}'),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
