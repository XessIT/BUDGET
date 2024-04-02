import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:mybudget/spent.dart';
import 'Trip.dart';
import 'TripEdit.dart';
import 'dashboard.dart';
import 'duplicate.dart';
import 'package:http/http.dart' as http;


class TripDashboard extends StatefulWidget {
  const TripDashboard({super.key});

  @override
  _TripDashboardState createState() => _TripDashboardState();
}


class _TripDashboardState extends State<TripDashboard> {
  List<Map<String, dynamic>> trips = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> tripData = []; // Change the type to a list of maps
  Map<String, dynamic> trip = {};

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/tripdashBoard.php'));
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<Map<String, dynamic>> parsedData = [];
      // Ensure that each item in the responseData list is of type Map<String, dynamic>
      responseData.forEach((dynamic item) {
        if (item is Map<String, dynamic>) {
          parsedData.add(item);
        }
      });
      setState(() {
        tripData = parsedData;
      });
    } else {
      print('Failed to load data');
    }
  }


  Future<void> closeTrip(String tripId) async {
    try {
      var response = await http.put(
        Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/tripdashboard.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'trip_id': tripId,
          'status': 'close', // Set the status to "close"
        }),
      );

      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> const TripDashboard()));
        print('Trip closed successfully');
      } else {
        print('Failed to close trip: ${response.body}');
        throw Exception('Failed to close trip');
      }
    } catch (e) {
      print('Exception while closing trip: $e');
      rethrow; // Rethrow the exception for higher-level error handling
    }
  }


  List<Map<String,dynamic>> spentData=[];
  Future<void> fetchTSpent(String? tripId) async {
    try {
      // print("trip Id:${widget.tripId}");
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php?table=trip_spent&trip_id=$tripId');
      final response = await http.get(url);
      print("id members URL :$url" );
      print("M response.statusCode :${response.statusCode}" );
      print("M response .body :${response.body}" );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List<dynamic>) {
          setState(() {
            spentData = responseData.cast<Map<String, dynamic>>();

          });
        } else {
          print('Invalid response data format');
        }
      } else {
        // Handle non-200 status code
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
    }
  }




  @override
  void initState() {
    super.initState();
    //_loadDataFromSharedPreferences();
    fetchData();
  }

  Future<void> _showAlertDialog() async {
    return showDialog(


      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select an option', style: Theme.of(context).textTheme.bodyLarge),
          insetPadding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.deepPurple),
          ),

          // contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // Customize padding for width and height
          content: SizedBox(
            width: 200, // Set your desired width
            height: 120,
            child: Container(
              // Adjust height as needed
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () {},
                    child: ListTile(
                      title: GestureDetector(
                        onTap: () {
                          // Handle text click, you can navigate or perform any action here
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetails(userId: '7', type: 'Friends Trip',)));
                        },
                        child: Text(
                          'Friends Trip',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                  /// Friendly Trip
                  TextButton
                    (
                    onPressed: () {  },
                    child: ListTile(
                      title: GestureDetector(

                        onTap: () {
                          // Handle text click, you can navigate or perform any action here
                         Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetails(userId: '7', type: "Trip Organizer",)));
                        },
                        child: Text('Trip Organizer',style:  Theme.of(context).textTheme.bodySmall),
                      ),
                    ),
                  ), /// Admisnstaive trip

                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TripDashboard())); // Close the dialog
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
              ),
              child: Text('Cancel',style: TextStyle(color: Colors.white)),
            ),
          ],
          backgroundColor: Colors.teal.shade50,

        );
      },
    );
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
                    _showAlertDialog();


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
                                  _showAlertDialog();
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
                ),                SizedBox(height: 5),
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
                for (var trip in tripData) buildTripContainer(context, trip),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return buildTripContainer(context, trips[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget buildTripContainer(BuildContext context, Map<String, dynamic> trip) {
    return GestureDetector (
      onTap: () {
        print("budget: ${trip['budget'].toString()}");
        print("budget: ${trip['id'].toString()}");
        print("budget: ${trip['member']}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpentDetails(
              budget: trip['budget'].toString(),
              tripid: trip['trip_id'].toString(),
              members: trip['members'].toString(),
             // expenses: const [],
              //expenses2: const [],
              receivedamnt:trip['received_amount'].toString(), tripname: '',

            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 350,
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Color(0xFF8155BA), width: 1),
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
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Trip Name: ${trip['trip_name']}', style: Theme.of(context).textTheme.labelMedium),
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
                      // PopupMenuItem(
                      //   child: Text("Trip Close"),
                      //   value: "Trip Close",
                      // ),
                    ],
                    onSelected: (value) {
                      if (value == "edit") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripEdit(
                                id: '7',
                                tripId: trip['trip_id'],
                                fromdate:trip['from_date'],
                                toDate:trip['to_date'],
                                tripType:trip['trip_type'],
                                tripName:trip['trip_name']
                            ),
                          ),
                        );
                      }
                      else if (value == "delete") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Delete"),
                              content: Text("Are you sure you want to delete this trip?"),
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
                                    // Send DELETE request to delete data
                                    var response = await http.delete(
                                      Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/trip.php'),
                                      headers: <String, String>{
                                        'Content-Type': 'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode(<String, String>{
                                        'trip_id': trip['trip_id'],
                                      }),
                                    );

                                    if (response.statusCode == 200) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const TripDashboard()));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to delete data')));
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }

                      else if (value == "Trip Close") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Delete"),
                              content: Text(
                                  "Are you sure you want to Close this trip?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Yes"),
                                  onPressed: () async {
                                    await closeTrip(trip['trip_id']);
                                    // Send DELETE request to delete data
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
                              text: '${trip['location']}',
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
                              text: '${trip['members']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
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
                              text: '${trip['budget']}',
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
                              text: '${trip['received_amount']}',
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

