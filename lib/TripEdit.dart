import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mybudget/tripdashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'TripView.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TripEdit extends StatefulWidget {
  final String tripId;

  const TripEdit({Key? key, required this.tripId}) : super(key: key);

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

  void _loadDataForTrip() async {
    // Fetch data from SharedPreferences using widget.tripId
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Use widget.tripId to construct keys and get the data
    String tripNameKey = '${widget.tripId}:tripName';
    String sourceKey = '${widget.tripId}:source';
    String fromDateKey = '${widget.tripId}:fromDate';
    String toDateKey = '${widget.tripId}:toDate';
    String noOfPersonsKey = '${widget.tripId}:noOfPerson';
    String totalBudgetKey = '${widget.tripId}:totalBudget';
    String personsKey = '${widget.tripId}:persons';
    String categoriesKey = '${widget.tripId}:expenses';

    setState(() {
      // Use the fetched data to update the TextEditingControllers
      _tripNameController.text = prefs.getString(tripNameKey) ?? '';
      _sourceController.text = prefs.getString(sourceKey) ?? '';
      fromDate.text = prefs.getString(fromDateKey) ?? '';
      toDate.text = prefs.getString(toDateKey) ?? '';
      _noOfPersonController.text = prefs.getString(noOfPersonsKey) ?? '';
      totalBudget.text = prefs.getString(totalBudgetKey) ?? "";
      List<String>? personsList = prefs.getStringList(personsKey);
      expenses2 = personsList?.map((person) {
        List<String> parts = person.split(':');
        return {
          'name': TextEditingController(text: parts[0]),
          'perAmount': TextEditingController(text: parts[1]),
        };
      }).toList() ??
          [];
      List<String>? categoriesList = prefs.getStringList(categoriesKey);
      expenses = categoriesList?.map((categories) {
        List<String> parts = categories.split(':');
        return {
          'category': TextEditingController(text: parts[0]),
          'amount': TextEditingController(text: parts[1]),
        };
      }).toList() ??
          [];
    });
  }


  void _updateDataInSharedPreferences(String tripId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String roundedAmount = calculateAmountPerHead();

    prefs.setString('$tripId:tripName', _tripNameController.text);
    prefs.setString('$tripId:noOfPerson', _noOfPersonController.text);
    prefs.setString('$tripId:source', _sourceController.text);
    prefs.setString('$tripId:fromDate', fromDate.text);
    prefs.setString('$tripId:toDate', toDate.text);
    prefs.setString('$tripId:totalBudget', totalBudget.text);
    prefs.setString('$tripId:totalAmountPerson', totalAmountPerson.toString());
    prefs.setString('$tripId:roundedAmount', roundedAmount);

    List<String> personsList = expenses2.map((person) {
      final name =
          person['name']?.text ?? ''; // Use null-aware operator to handle null
      final perAmount = person['perAmount']?.text ??
          ''; // Use null-aware operator to handle null
      return '$name:$perAmount';
    }).toList();
    prefs.setStringList('$tripId:persons', personsList);

    List<String> categoriesList = expenses.map((person) {
      final categories = person['category']?.text ??
          ''; // Use null-aware operator to handle null
      final amount = person['amount']?.text ??
          ''; // Use null-aware operator to handle null
      return '$categories:$amount';
    }).toList();
    prefs.setStringList('$tripId:expenses', categoriesList);
  }

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
            'name': TextEditingController(),
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
  double _updateTotalBudget2() {
    totalAmountPerson = 0.0;
    for (var expense2 in expenses2) {
      double amount = double.tryParse(expense2['perAmount']!.text) ?? 0.0;
      totalAmountPerson += amount;
    }
    return totalAmountPerson;
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  @override
  void initState() {
    super.initState();
    _addCategoryField();
    _addCategoryField2();
    //_updateTotalBudget();
    setState(() {
      _updateTotalBudget2();
    });
    _loadDataForTrip();
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  'Total Amount: ₹${_updateTotalBudget2().toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
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
                        Text(
                          'Total Received Amount: ${totalAmountPerson.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),
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
                              } else if (_isExpensesListEmpty()) {
                                _showErrorToast('Please add members list');
                              } else if (_areExpensesFieldsEmpty()) {
                                _showErrorToast(
                                    'Name and Amount cannot be empty');
                              } else {
                                _updateDataInSharedPreferences(widget.tripId);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content:
                                      const Text('Update successfully'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
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
                      ],
                    ),
                    // Text('Total Budget: $totalBudget',
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
