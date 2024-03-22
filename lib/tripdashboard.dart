import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:mybudget/spent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Trip.dart';
import 'TripEdit.dart';
import 'dashboard.dart';
import 'duplicate.dart';

class TripDashboard extends StatefulWidget {
  const TripDashboard({super.key});

  @override
  _TripDashboardState createState() => _TripDashboardState();
}
class _TripDashboardState extends State<TripDashboard> {
  List<Map<String, dynamic>> trips = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadDataFromSharedPreferences();
  }

  void _loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> tripIds = prefs.getStringList('reportIds') ?? [];
    List<Map<String, dynamic>> tempTrips = [];

    for (String tripId in tripIds) {
      String tripNameKey = '$tripId:tripName';
      String sourceKey = '$tripId:source';
      String fromDateKey = '$tripId:fromDate';
      String toDateKey = '$tripId:toDate';
      String totalBudgetKey = '$tripId:totalBudget';
      String noOfPersonKey = '$tripId:noOfPerson';
      String personKey = '$tripId:persons';
      String expensesKey = '$tripId:expenses';
      String totalAmountPersonKey = '$tripId:totalAmountPerson';

      String tripName = prefs.getString(tripNameKey) ?? '';
      String source = prefs.getString(sourceKey) ?? '';
      String fromDate = prefs.getString(fromDateKey) ?? '';
      String toDate = prefs.getString(toDateKey) ?? '';
      String noOfPerson = prefs.getString(noOfPersonKey) ?? '';
      String totalBudget = prefs.getString(totalBudgetKey) ?? '';
      String totalAmountPerson = prefs.getString(totalAmountPersonKey) ?? '';


      List<String>? expensesListPerson = prefs.getStringList(personKey);
      List<String>? expensesList = prefs.getStringList(expensesKey);

      List<Map<String, String>> expenses2 = [];
      if (expensesListPerson != null) {
        expenses2 = expensesListPerson.map((expense2) {
          List<String> parts = expense2.split(':');
          return {
            'name': parts[0],
            'perAmount': parts[1],
          };
        }).toList();
      }
      List<Map<String, String>> expenses = [];
      if (expensesList != null) {
        expenses = expensesList.map((expense) {
          List<String> parts = expense.split(':');
          return {
            'category': parts[0],
            'amount': parts[1],
          };
        }).toList();
      }

      tempTrips.add({
        'tripId': tripId, // Include tripId
        'tripName': tripName,
        'source': source,
        'fromDate': fromDate,
        'toDate': toDate,
        'totalBudget': totalBudget.toString(),
        'totalAmountPerson': totalAmountPerson.toString(),
        'noOfPerson': noOfPerson,
        'persons': expenses2,
        'expenses': expenses,
      });
    }
    setState(() {
      trips = tempTrips;
    });
  }


  Future<void> _deleteTrip(String tripId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tripIds = prefs.getStringList('reportIds');

    if (tripIds != null) {
      tripIds.remove(tripId);
      await prefs.setStringList('reportIds', tripIds);

      // Remove other trip data from shared preferences
      await prefs.remove('$tripId:tripName');
      await prefs.remove('$tripId:source');
      await prefs.remove('$tripId:fromDate');
      await prefs.remove('$tripId:toDate');
      await prefs.remove('$tripId:totalBudget');
      await prefs.remove('$tripId:noOfPerson');
      await prefs.remove('$tripId:persons');
      await prefs.remove('$tripId:expenses');
      await prefs.remove('$tripId:totalAmountPerson');

      // Reload data from SharedPreferences
      _loadDataFromSharedPreferences();
    }
  }

  bool isContainerExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),

        child:AppBar(
          title:  Text("Trip",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  const DashBoard()));
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
          backgroundColor:  Color(0xFF8155BA),

        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TripDetails()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8155BA), Colors.lightBlueAccent],
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
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TyperAnimatedTextKit(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TripDetails()),
                                  );
                                },
                                isRepeatingAnimation: true,
                                speed: Duration(milliseconds: 100),
                                text: ['+ Make your Trip'],
                                textStyle: Theme.of(context).textTheme.labelMedium
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Visibility(
                  visible: trips.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Your Trips',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    Trip trip = Trip(
                      name: trips[index]['tripName'] ?? 'No Name',
                      id: trips[index]['tripId'] ?? 'No Name',
                      date: trips[index]['source'] ?? 'No Date',
                      budget: trips[index]['totalBudget'] ?? '',
                      members: trips[index]['noOfPerson'] ?? '0',
                      expenses: trips[index]['expense'] ?? [],
                      totalAmountPerson: trips[index]['totalAmountPerson'] ?? '0.0',
                    );
                    return buildTripContainer(context, trip, index);
                  },
                ),

/*
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the second page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BudgetApp()),
                    );
                  },
                  child: Text('Click'),
                ),
*/

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTripContainer(BuildContext context, Trip trip, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpentDetails(
              tripId: trip.id,
              budget: trip.budget,
              tripid: trip.id,
              members: trip.members,
              receivedamnt: trip.totalAmountPerson,
              expenses: trips[index]['expenses'],
              expenses2: trips[index]['persons'],
            ),
          ),
        );
        // Add logic for tapping the container if needed
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 350,
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white, // Set the background color to white
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Color(0xFF8155BA), width: 1), // Add a black border
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('Trip Name: ${trip.name}', style: Theme.of(context).textTheme.labelMedium),
                  ),
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: Text("Edit"),
                        value: "edit",
                      ),
                      PopupMenuItem(
                        child: Text("Delete"),
                        value: "delete",
                      ),
                      PopupMenuItem(
                        child: Text("TripClose"),
                        value: "TripClose",
                      ),
                    ],
                    onSelected: (value) {
                      if (value == "edit") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripEdit(
                              tripId: trips[index]['tripId'],
                            ),
                          ),
                        );
                      } else if (value == "delete") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Delete"),
                              content: Text(
                                  "Are you sure you want to delete this trip?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Delete"),
                                  onPressed: () async {
                                    // Call the delete function here
                                    await _deleteTrip(trips[index]['tripId']);
                                    Navigator.of(context).pop();
                                  },
                                ),

                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Place        : ',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: '${trip.date}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Members : ',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: '${trip.members}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                    /*  RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'id : ',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: '${trip.id}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),*/
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Budget   : ₹',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: '${double.parse(trip.budget).toStringAsFixed(2)}',
                              //text: '${trip.budget}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Received: ₹',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: '${double.parse(trip.totalAmountPerson).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5,)
            ],
          ),
        ),
      ),
    );
  }
}
class Trip {
  final String name;
  final String id;
  final String date;
  final String budget;
  final String totalAmountPerson;
  final String members;
  final List<Map<String, String>> expenses;
  Trip({
    required this.name,
    required this.id,
    required this.date,
    required this.budget,
    required this.totalAmountPerson,
    required this.members,
    required this.expenses,
  });
}
