import 'dart:convert';

import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mybudget/tripdashboard.dart';
import 'package:http/http.dart'as http;

class TripEdit extends StatefulWidget {
  final String tripId;
  final String id;
  final String fromdate;
  final String toDate;
  final String tripType;
  final String tripName;

  const TripEdit({Key? key,
    required this.tripId,
    required this.id,
    required this.fromdate,
    required this.toDate,
    required this.tripType,
    required this.tripName
  }) : super(key: key);

  @override
  State<TripEdit> createState() => _TripEditState();
}

class _TripEditState extends State<TripEdit> {
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _noOfPersonController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController totalBudget = TextEditingController();

  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  List<Map<String, TextEditingController>> expenses = [];
  List<Map<String, TextEditingController>> expenses2 = [];
  double totalAmountPerson = 0.0;
  bool istextfield = false;
  bool isTableVisible = false;
  List<Map<String, dynamic>> tripData = [];

  //double totalBudget = 0.0;
  void updateAmountPerHead() {
    setState(() {
      // This will trigger a rebuild when either amount or no of persons change.
    });
  }

  bool _isExpensesListEmpty() {
    return expenses2.isEmpty;
  }

  bool _areExpensesFieldsEmpty() {
    return expenses2.any((expense) =>
    expense['name']!.text.isEmpty || expense['perAmount']!.text.isEmpty);
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  String calculateAmountPerHead() {
    double amount = double.tryParse(totalBudget.text) ?? 0.0;
    int noOfPersons = int.tryParse(_noOfPersonController.text) ?? 1;

    if (noOfPersons <= 0) {
      return '0';
    }

    // Calculate amount per head
    double amountPerHead = (amount / noOfPersons);

    // Round to the nearest integer
    int roundedAmount = amountPerHead.round();

    // If the decimal part is greater than or equal to 0.5, round up; otherwise, round down
    if ((amountPerHead - roundedAmount).abs() >= 0.5) {
      return (roundedAmount + 1).toString();
    } else {
      return roundedAmount.toStringAsFixed(2);
    }
  }
  int? countNumber = 0;


  void _addCategoryField() {
    setState(() {
      expenses.add({
        'category': TextEditingController(),
        'amount': TextEditingController(),
      });

      //_updateTotalBudget();
    });
  }

  void _addCategoryField2() {
    try {
      int maxRows = int.parse(_noOfPersonController.text);

      // Check if the current number of rows is less than or equal to the specified limit
      if (expenses2.length < maxRows) {
        setState(() {
          expenses2.add({
            'id': TextEditingController(),
            'name': TextEditingController(),
            'mobile': TextEditingController(),
            'perAmount': TextEditingController(),
          });

          _updateTotalBudget2();
        });
      } else {
        // Display a message or handle the case where the limit is reached
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text(
                  'Maximum number of members reached.\nif you want to add more members increase \nno of members count !'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child:
                  const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle the FormatException
      print('Error parsing the number of members: $e');
      // You might want to display an error message to the user here
    }
  }


/*  void _updateTotalBudget() {
    totalBudget = 0.0;
    for (var expense in expenses) {
      double amount = double.tryParse(expense['amount']!.text) ?? 0.0;
      totalBudget += amount;
    }
  }*/
  double valueget = 0.0;
  double valueget3=0.0;
  double _updateTotalBudget2() {
    double valueget = 0.0;
    for (var expense2 in expenses2) {
      double amount = double.tryParse(expense2['perAmount']!.text) ?? 0.0;
      valueget += amount;
      setState(() {
        totalAmountPerson =valueget;
        valueget3 =totalAmountPerson+valueget2;


      });
    }
    return totalAmountPerson;
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Future<void> AddTrip() async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php');
      final DateTime fromparsedDate =
      DateFormat('dd-MM-yyyy').parse(fromDate.text);
      final fromformattedDate = DateFormat('yyyy-MM-dd').format(fromparsedDate);
      final DateTime toparsedDate =
      DateFormat('dd-MM-yyyy').parse(toDate.text);
      final toformattedDate = DateFormat('yyyy-MM-dd').format(toparsedDate);
      print("trip url:$url");

      List<Map<String, String>> membersData = [];
      for (var expense2 in expenses2) {
        membersData.add({
          'name': expense2['name']!.text,
          'mobile': expense2['mobile']!.text,
          'amount': expense2['perAmount']!.text,
        });
      }
      final response = await http.post(
        url,
        body: jsonEncode({
          "trip_type": tripType,
          "trip_name": _tripNameController.text,
          "location": _sourceController.text,
          "from_date": fromformattedDate,
          "to_date": toformattedDate,
          "budget": totalBudget.text,
          "members": _noOfPersonController.text,
          "uid": "7",
          "trip_id": widget.tripId,
          "members_data": membersData,
          "createdOn": DateTime.now().toString(),
        }),
      );
      // print("T Response body: ${response.body}");
      // print("T Response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Trip added successfully!");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Trip Added Successfully")));
        // print("T Response body: ${response.body}");
        // print("T Response code: ${response.statusCode}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error during trip addition: $e");
      // Handle error as needed
    }
  }
  @override
  void initState() {
    super.initState();
    _addCategoryField();
    _addCategoryField2();
    fetchTCreation();
    fetchTMembers();
    setState(() {
      _updateTotalBudget2();
    });
  }
  String? id ="7";
  List<Map<String,dynamic>> creationData=[];
  String? tripType="";
  Future<void> fetchTCreation() async {
    try {
      print("trip Id:${widget.tripId}");

      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php?table=trip_creation&uid=${widget.id}&trip_id=${widget.tripId}');
      final response = await http.get(url);
      print("id fetch URL :$url" );

      if (response.statusCode == 200) {
        print("response.statusCode :${response.statusCode}" );
        print("response .body :${response.body}" );
        final responseData = json.decode(response.body);
        if (responseData is List<dynamic>) {
          setState(() {
            creationData = responseData.cast<Map<String, dynamic>>();
            if (creationData.isNotEmpty) {
              setState(() {
                tripType = creationData[0]["trip_type"];
                _tripNameController.text = creationData[0]["trip_name"];
                _sourceController.text = creationData[0]["location"];
                fromDate.text = creationData[0]["from_date"];
                toDate.text = creationData[0]["to_date"];
                totalBudget.text = creationData[0]["budget"];
                _noOfPersonController.text = creationData[0]["members"];

                print("Trip_creation data--$creationData" );

              });
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("This mobile number is not member. Enter the member mobile number."),
            ),
          );
          //    referreridcotroller.clear();
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
  TextEditingController mName = TextEditingController();
  TextEditingController mNo = TextEditingController();
  TextEditingController amt = TextEditingController();

  List<Map<String,dynamic>> membersData=[];

  double totalAmt=0.0;
  String? totalAmountString="";


  Future<void> fetchTMembers() async {
    try {
      print("trip Id:${widget.tripId}");
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php?table=trip_members&trip_id=${widget.tripId}');
      final response = await http.get(url);
      print("id members URL :$url");
      print("M response.statusCode :${response.statusCode}");
      print("M response .body :${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        for(int i =0;i<responseData.length;i++){
          double? checkvalue =0.0;
          checkvalue =double.tryParse(responseData[i]["amount"])??0.0;
          valueget2 +=checkvalue;
        }
        if (responseData is List<dynamic>) {

          setState(() {
            membersData = responseData.cast<Map<String, dynamic>>();
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

  bool visible = false;
  Future<void> updateTrip(String id) async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php');
      final DateTime fromparsedDate =
      DateFormat('dd-MM-yyyy').parse(fromDate.text);
      //fromdatecontrollers is --- fromDate.text
      final fromformattedDate = DateFormat('yyyy-MM-dd').format(fromparsedDate);
      final DateTime toparsedDate =
      DateFormat('dd-MM-yyyy').parse(toDate.text);
      final toformattedDate = DateFormat('yyyy-MM-dd').format(toparsedDate);
      //todatecontrollers is --- toDate.text

      print("Update url:$url");

      List<Map<String, String>> membersData = [];
      for (var expense2 in expenses2) {
        membersData.add({
          'id': id,
          'name': mName.text,
          'mobile': mNo.text,
          'amount': amt.text,
        });
      }

      final response = await http.put(
        url,
        body: jsonEncode({
          "trip_type":widget.tripType,
          "trip_name": _tripNameController.text,
          "location": _sourceController.text,
          "from_date":fromformattedDate,
          "to_date":toformattedDate,
          "budget": totalBudget.text,
          "members": _noOfPersonController.text,
          "trip_id":widget.tripId,
          "uid":widget.id,
          "members_data": membersData,
          "createdOn": DateTime.now().toString(),
        }),
      );

      print("U Response body: ${response.body}");
      print("U Response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Trip Updated successfully!");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Trip Updated Successfully")));
        // print("T Response body: ${response.body}");
        // print("T Response code: ${response.statusCode}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error during trip addition: $e");
      // Handle error as needed
    }
  }
  Future<void> updateCreation() async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php');
      final DateTime fromparsedDate =
      DateFormat('dd-MM-yyyy').parse(fromDate.text);
      //fromdatecontrollers is --- fromDate.text
      final fromformattedDate = DateFormat('yyyy-MM-dd').format(fromparsedDate);
      final DateTime toparsedDate =
      DateFormat('dd-MM-yyyy').parse(toDate.text);
      final toformattedDate = DateFormat('yyyy-MM-dd').format(toparsedDate);
      //todatecontrollers is --- toDate.text

      print("Update url:$url");

      List<Map<String, String>> membersData = [];
      for (var expense2 in expenses2) {
        membersData.add({
          'name': mName.text,
          'mobile': mNo.text,
          'amount': amt.text,
        });
      }

      final response = await http.put(
        url,
        body: jsonEncode({
          "trip_type":widget.tripType,
          "trip_name": _tripNameController.text,
          "location": _sourceController.text,
          "from_date":fromformattedDate,
          "to_date":toformattedDate,
          "budget": totalBudget.text,
          "members": _noOfPersonController.text,
          "trip_id":widget.tripId,
          "uid":widget.id,
          "received_amount":valueget3 == 0.0? valueget2.toStringAsFixed(2):valueget3.toStringAsFixed(2),
          "members_data": membersData,
          "createdOn": DateTime.now().toString(),
        }),
      );

      print("U Response body: ${response.body}");
      print("U Response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Trip Updated successfully!");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Trip Updated Successfully")));
        // print("T Response body: ${response.body}");
        // print("T Response code: ${response.statusCode}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error during trip addition: $e");
      // Handle error as needed
    }
  }

  void saveSpentData(List<dynamic> spentExpenses, String tripId) async {
    final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/tripEdit_add.php');
    // Create a list to store expense data
    List<Map<String, dynamic>> expenseDataList = [];

    // Prepare expense data
    for (var expense in spentExpenses) {
      Map<String, dynamic> expenseData = {
        'member_name': expense['name'].text,
        'mobile': expense['mobile'].text,
        'amount': expense['perAmount'].text,
      };
      expenseDataList.add(expenseData);
    }

    // Make POST request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'trip_id': tripId,
        'tripspent': expenseDataList, // Send the expense data list
      }),
    );

    // Handle response
    if (response.statusCode == 200) {
      print("Response Status: ${response.statusCode}");
      print("Response body: ${response.body}");
      print('Data sent successfully!');
    } else {
      print('Failed to send data. Error: ${response.statusCode}');
    }
  }
  //double totalAmountPerson = 0;

  Future<void> delete(String id) async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/tripEdit.php?id=$id');
      final response = await http.delete(url);
      print("Delete Url: $url");
      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>TripEdit(tripId: widget.tripId,
          id: widget.id,
          fromdate: widget.fromdate,
          toDate: widget.toDate,
          tripType: widget.tripType,
          tripName: widget.tripName,


        )));
        // Success handling, e.g., show a success message
        // Navigator.pop(context);
      }
      else {
        // Error handling, e.g., show an error message
        print('Error: ${response.statusCode}');
      }
    }
    catch (e) {
      // Handle network or server errors
      print('Error making HTTP request: $e');
    }
  }

  double valueget2 =0.0;
  @override
  Widget build(BuildContext context) {


// Now 'totalAmount' holds the total of all amounts in 'membersData'
    print('Total Amount: $valueget2');
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          title: Text(
            "Trip Edit",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.navigate_before,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TripDashboard()));
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
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.only(left: 20.0, bottom: 16.0),
            title: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /*Text(
                  'Total Amount: ₹${_updateTotalBudget2().toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),*/
                if(creationData.isNotEmpty)
                  Text(valueget3 ==0.00?
                  'Total Amount: ₹ $valueget2': 'Total Received Amount: ₹ ${valueget3.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                /*const SizedBox(width: 10,),
                Text(
                  'Total Budget: $totalBudget',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),*/
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBarBubble(
        color: Color(0xFF8155BA),
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
      body: SingleChildScrollView(
        child: Container(
          // color: Colors.white70,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    width: 160,
                    child: TextFormField(
                      style: Theme.of(context).textTheme.labelMedium,
                      controller: _tripNameController,
                      onChanged: (value) {
                        String capitalizedValue = capitalizeFirstLetter(value);
                        _tripNameController.value =
                            _tripNameController.value.copyWith(
                              text: capitalizedValue,
                              selection: TextSelection.collapsed(
                                  offset: capitalizedValue.length),
                            );
                      },
                      decoration: InputDecoration(
                          labelText: 'Trip Name',
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(
                            // borderRadius: BorderRadius.circular(
                            //   10,
                            // ),
                          )),
                    ),
                  ),

                  /// Trip Name
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    height: 40,
                    width: 160,
                    child: TextFormField(
                      style: Theme.of(context).textTheme.labelMedium,
                      controller: _sourceController,
                      decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(
                            // borderRadius: BorderRadius.circular(
                            //   10,
                            // ),
                          )),
                      onChanged: (value) {
                        String capitalizedValue = capitalizeFirstLetter(value);
                        _sourceController.value =
                            _sourceController.value.copyWith(
                              text: capitalizedValue,
                              selection: TextSelection.collapsed(
                                  offset: capitalizedValue.length),
                            );
                      },
                    ),
                  ),

                  /// Location
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    width: 160,
                    child: TextFormField(
                      style: Theme.of(context).textTheme.labelMedium,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2300),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFF8155BA),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickDate == null) return;
                        {
                          setState(() {
                            fromDate.text =
                                DateFormat('dd-MM-yyyy').format(pickDate);
                          });
                        }
                      },
                      controller:
                      fromDate, // Set the initial value of the field to the selected date
                      decoration: InputDecoration(
                        filled: true,
                        suffixIcon: Icon(
                          Icons.date_range,
                          size: 14,
                        ),
                        fillColor: Colors.white,
                        labelText: "From",
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12.0), // Adjust padding values
                        border: OutlineInputBorder(
                          //  borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  /// From date
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    height: 40,
                    width: 160,
                    child: TextFormField(
                      style: Theme.of(context).textTheme.labelMedium,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2300),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFF8155BA),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickDate == null) return;
                        {
                          setState(() {
                            toDate.text =
                                DateFormat('dd-MM-yyyy').format(pickDate);
                          });
                        }
                      },
                      controller: toDate,
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.date_range,
                          size: 14,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12.0), // Adjust padding values
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "To",
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        border: OutlineInputBorder(
                          //  borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  /// To date
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    width: 160,
                    child: TextFormField(
                      style: Theme.of(context).textTheme.labelMedium,
                      controller: totalBudget,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => updateAmountPerHead(),
                      decoration: InputDecoration(
                        labelText: ' Budget',
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                          size: 14,
                        ),
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12.0), // Adjust padding values
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  /// No of person
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    height: 40,
                    width: 160,
                    child: TextFormField(
                      style: Theme.of(context).textTheme.labelMedium,
                      controller: _noOfPersonController,
                      onChanged: (_) => updateAmountPerHead(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'No of Members',
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12.0), // Adjust padding values
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              /* if (totalBudget.text.isNotEmpty && _noOfPersonController.text.isNotEmpty)
                RichText(
                  text: TextSpan(
                    text: "Each person will bear the amount of ₹. ",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.green,
                    ),
                    children: [
                      TextSpan(
                        text: calculateAmountPerHead(),
                        style: TextStyle(
                          color: Colors.green.withOpacity(0.5), // Adjust opacity as needed
                        ),
                      ),
                    ],
                  ),
                ),*/

              if (totalBudget.text.isNotEmpty &&
                  _noOfPersonController.text.isNotEmpty)
                Container(
                  width: 330,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 1.0, // Border width
                    ),
                    // borderRadius: BorderRadius.all(Radius.circular(8.0)), // Optional: Set border radius
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "Each Member will bear the amount of  ₹${calculateAmountPerHead()}",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),
                        //valueget3 == 0.0? valueget2.toStringAsFixed(2):valueget3.toStringAsFixed(2)
                        Text(valueget3 ==0.0?
                        'Total Amount : ₹ $valueget2': 'Total Received Amount: ${valueget3.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),
                        /*Text(valueget3 ==0.0?
                        'Total Received Amount: ${valueget2.toStringAsFixed(2)}': 'Total Received Amount: ${valueget3.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              Container(
                // color: Colors.grey.shade200,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                              boxShadow: const [],
                              gradient: const LinearGradient(
                                // Gradient background
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.white70, Colors.white70],
                              ),
                            ),
                            child: Column(
                              children: [
                                // for (var i = 0; i < expenses2.length; i++)
                                for (var expense2 in expenses2)

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, left: 8, right: 8, bottom: 16),
                                    child: Row(
                                      children: [


                                        Expanded(
                                          child: TextFormField(
                                            controller: expense2['name'],
                                            style:
                                            const TextStyle(fontSize: 14),
                                            onChanged: (value) {
                                              String capitalizedValue =
                                              capitalizeFirstLetter(value);
                                              expense2['name']?.value =
                                                  expense2['name']!
                                                      .value
                                                      .copyWith(
                                                    text: capitalizedValue,
                                                    selection: TextSelection
                                                        .collapsed(
                                                        offset:
                                                        capitalizedValue
                                                            .length),
                                                  );
                                              setState(() {
                                                // _updateTotalBudget();
                                              });
                                            },
                                            decoration: InputDecoration(
                                                labelText: expense2['name']!
                                                    .text
                                                    .isEmpty
                                                    ? 'Name'
                                                    : null, // Hide label when amount is entered
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium),
                                            // keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: expense2['mobile'],
                                            style:
                                            const TextStyle(fontSize: 14),

                                            decoration: InputDecoration(
                                                prefixText: "+91",
                                                labelText: expense2['mobile']!
                                                    .text
                                                    .isEmpty
                                                    ? 'Mobile'
                                                    : null, // Hide label when amount is entered
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(10),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: expense2['perAmount'],
                                            style:
                                            const TextStyle(fontSize: 14),
                                            onChanged: (value) {
                                              setState(() {
                                                _updateTotalBudget2();
                                              });
                                            },
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  7)
                                            ],
                                            decoration: InputDecoration(
                                                labelText: expense2[
                                                'perAmount']!
                                                    .text
                                                    .isEmpty
                                                    ? 'Amount'
                                                    : null, // Hide label when amount is entered
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors
                                                  .red), // You can change the icon here
                                          onPressed: () {
                                            setState(() {
                                              expenses2.removeAt(
                                                  expenses2.indexOf(expense2));
                                              _updateTotalBudget2();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Add .00 to the entered amount for each expense
                              for (var i = 0; i < expenses2.length; i++) {
                                var currentAmount =
                                    expenses2[i]['perAmount']!.text;
                                if (!currentAmount.contains('.')) {
                                  expenses2[i]['perAmount']!.text =
                                  '$currentAmount.00';
                                }
                              }
                            });
                            _addCategoryField2();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.deepPurple, // Change button color here
                            elevation: 5, // Add elevation
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (totalBudget.text.isEmpty ||
                                  _noOfPersonController.text.isEmpty ||
                                  _tripNameController.text.isEmpty ||
                                  _sourceController.text.isEmpty ||
                                  fromDate.text.isEmpty ||
                                  toDate.text.isEmpty) {
                                _showErrorToast('Please fill the all fields');
                              } /*else if (_isExpensesListEmpty()) {
                                _showErrorToast('Please add members list');
                              }*/ /*else if (_areExpensesFieldsEmpty()) {
                                _showErrorToast(
                                    'Name and Amount cannot be empty');
                              } */else {
                                updateCreation();
                                //   _updateDataInSharedPreferences(widget.tripId);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content:
                                      const Text('Update successfully'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            updateCreation();
                                            saveSpentData(expenses2, widget.tripId);
                                            // AddTripmember();
                                            // updateTrip();
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const TripDashboard()));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .green, // Change button color here
                                            elevation: 5, // Add elevation
                                          ),
                                          child: const Text('Ok',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.deepPurple, // Change button color here
                              elevation: 5, // Add elevation
                            ),
                            child: const Text('Update',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        /* Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (totalBudget.text.isEmpty ||

                                  _noOfPersonController.text.isEmpty ||
                                  _tripNameController.text.isEmpty ||
                                  _sourceController.text.isEmpty ||
                                  fromDate.text.isEmpty ||
                                  toDate.text.isEmpty) {
                                _showErrorToast('Please fill the all fields');
                              } *//*else if (_isExpensesListEmpty()) {
                                _showErrorToast('Please add members list');
                              }*//* *//*else if (_areExpensesFieldsEmpty()) {
                                _showErrorToast(
                                    'Name and Amount cannot be empty');
                              } *//*else {
                                saveSpentData(expenses2, widget.tripId);

                                //   _updateDataInSharedPreferences(widget.tripId);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.deepPurple, // Change button color here
                              elevation: 5, // Add elevation
                            ),
                            child: const Text('Submit',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),*/
                      ],
                    ),
                    // Text('Total Budget: $totalBudget',
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    // ),
                  ],
                ),
              ),

              Container(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Table(
                          border: TableBorder.all(),
                          defaultColumnWidth:const FixedColumnWidth(90.0),
                          columnWidths: const <int, TableColumnWidth>{
                            0:FixedColumnWidth(100),
                            1:FixedColumnWidth(100),
                            2:FixedColumnWidth(70),
                            4:FixedColumnWidth(50),
                            5:FixedColumnWidth(50),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          // s.no
                          children: [TableRow(children:[
                            //Name
                            TableCell(child:Center(child: Text('Members',style: TextStyle(fontSize: 16, color: Colors.black)),)),
                            // company name

                            TableCell(child:Center(child: Text('Mobile',style: TextStyle(fontSize: 16, color: Colors.black)),)),

                            TableCell(child:Center(child: Text('Amount',style: TextStyle(fontSize: 16, color: Colors.black)),)),
                            //Email
                            TableCell(child:Center(child: Column(children: [SizedBox(height: 8,), Text('Detele', style: TextStyle(fontSize: 16, color: Colors.black)), SizedBox(height: 8,),],),)),
                            // Chapter
                            TableCell(child: Center(child: Text('Edit', style: TextStyle(fontSize: 16, color: Colors.black)),))]),

                            for(var i = 0 ;i < membersData.length; i++) ...[

                              TableRow(
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  children:[
                                    // 1 Table row contents

                                    //2 name
                                    TableCell(child: Center(child: Text('${membersData[i]["member_name"] ?? ''}',),)),
                                    // 3 company name
                                    TableCell(child:Center(child: Text('${membersData[i]["mobile"]?? ''}',),)),
                                    // 4 email
                                    TableCell(child:Center(child: Text('${membersData[i]["amount"]?? ''}',),)),

                                    TableCell(child: Center(child:
                                    IconButton(
                                        onPressed: (){
                                          showDialog(
                                              context: context,
                                              builder: (ctx) =>
                                              // Dialog box for register meeting and add guest
                                              AlertDialog(
                                                backgroundColor: Colors.grey[800],
                                                title: const Text('Delete',
                                                    style: TextStyle(color: Colors.white)),
                                                content: const Text("Do you want to Delete the Member?",
                                                    style: TextStyle(color: Colors.white)),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () async{
                                                        delete(membersData[i]["id"]);
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                            content: Text("You have Successfully Deleted")));
                                                      },
                                                      child: const Text('Yes')),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('No'))
                                                ],
                                              )
                                          );
                                        }, icon: const Icon(Icons.delete,color: Colors.red,)))),
                                    // 5 chapter
                                    TableCell(child:Center(
                                        child:IconButton(
                                            onPressed: (){
                                              showDialog<void>(
                                                context: context,
                                                builder: (BuildContext dialogContext) {
                                                  return AlertDialog(
                                                    backgroundColor: Colors.white,
                                                    title: const Text('Edit',),
                                                    content:  SizedBox(width: 300,
                                                      child: Column(
                                                        children: [

                                                          SizedBox(
                                                            width: 16,
                                                          ),

                                                          /// Cargories

                                                          SizedBox(width: 16),
                                                          Expanded(
                                                            child: TextFormField(
                                                              controller: mName = TextEditingController(text: membersData[i]['member_name']),
                                                              style: const TextStyle(fontSize: 14),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  //updatetotalspent();
                                                                  // updateTrip();
                                                                  _updateTotalBudget2();
                                                                  setState(() {
                                                                    //    errormsg = null;
                                                                  });
                                                                });
                                                              },
                                                              /*  decoration: InputDecoration(
                                                              //   hintText: monthlyexpenses[i]
                                                              //   ['monthlyamount']!
                                                              //       .text
                                                              //       .isEmpty
                                                              //       ? 'Rs'
                                                              //       : null,
                                                              //   hintStyle: const TextStyle(
                                                              //       fontSize: 16,
                                                              //       color: Colors.black),
                                                              // ),
                                                              keyboardType: TextInputType.number,
                                                            ),*/
                                                            ),

                                                            /// Amount
                                                          ),
                                                          Expanded(
                                                            child: TextFormField(
                                                              controller: mNo = TextEditingController(text: membersData[i]['mobile']),
                                                              style: const TextStyle(fontSize: 14),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  //updatetotalspent();
                                                                  // updateTrip();
                                                                  _updateTotalBudget2();
                                                                  setState(() {
                                                                    //    errormsg = null;
                                                                  });
                                                                });
                                                              },
                                                            ),

                                                            /// Amount
                                                          ),
                                                          Expanded(
                                                            child: TextFormField(
                                                              controller: amt = TextEditingController(text: membersData[i]['amount']),
                                                              style: const TextStyle(fontSize: 14),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  //updatetotalspent();
                                                                  // updateTrip();
                                                                  _updateTotalBudget2();
                                                                  setState(() {
                                                                    //    errormsg = null;
                                                                  });
                                                                });
                                                              },
                                                              /*  decoration: InputDecoration(
                                                              //   hintText: monthlyexpenses[i]
                                                              //   ['monthlyamount']!
                                                              //       .text
                                                              //       .isEmpty
                                                              //       ? 'Rs'
                                                              //       : null,
                                                              //   hintStyle: const TextStyle(
                                                              //       fontSize: 16,
                                                              //       color: Colors.black),
                                                              // ),
                                                              keyboardType: TextInputType.number,
                                                            ),*/
                                                            ),

                                                            /// Amount
                                                          )


                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          TextButton(
                                                            child: const Text('Ok',),
                                                            onPressed: () {

                                                              updateTrip(membersData[i]["id"]);
                                                              Navigator.pop(context); // Dismiss alert dialog
                                                            },
                                                          ),
                                                          TextButton(
                                                            child:  const Text('Cancel',),
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              // Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                                                            },
                                                          ),
                                                        ],
                                                      ),

                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(Icons.edit_note,color: Colors.blue,)))),
                                  ]
                              ),
                            ]
                          ]   )
                  )
              ),

              // OutlinedButton(onPressed: (){
              //   saveSpentData(expenses2, widget.tripId);
              //   //  addMembers();
              // }, child: Text("test"))
            ],
          ),
        ),
      ),
    );
  }
}
