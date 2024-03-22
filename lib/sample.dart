import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';


/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _budgetController = TextEditingController();
  String _budgetKey = "budget_list_key";

  List<String> _budgetList = [];

  @override
  void initState() {
    super.initState();
    _loadBudgetList();
  }

  Future<void> _loadBudgetList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _budgetList = prefs.getStringList(_budgetKey) ?? [];
    });
  }

  Future<void> _saveBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _budgetList.add(_budgetController.text);
    prefs.setStringList(_budgetKey, _budgetList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(labelText: 'Enter Budget'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveBudget();
                await _loadBudgetList(); // Reload the list after saving
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Budget saved successfully!'),
                  ),
                );
              },
              child: Text('Save Budget'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _loadBudgetList();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Budget list loaded successfully!'),
                  ),
                );
              },
              child: Text('Load Budget List'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _budgetList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_budgetList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

/*
class InsertPage extends StatefulWidget {
  @override
  _InsertPageState createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> insertData() async {
    try {
      final url = Uri.parse("http://localhost/BUDGET/lib/BudgetApi/sample.php");
      print(url);
      final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},

        body: jsonEncode({
          'name': nameController.text,
          'email': emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("Data inserted successfully!");
      } else {
        print("Failed to insert data. ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                insertData();
              },
              child: Text('Insert Data'),
            ),
          ],
        ),
      ),
    );
  }
}

*/



import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class TripBudgetScreen extends StatefulWidget {
  @override
  _TripBudgetScreenState createState() => _TripBudgetScreenState();
}

class _TripBudgetScreenState extends State<TripBudgetScreen> {
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _numberOfPersonsController = TextEditingController();
  List<List<TextEditingController>> controllers = [];
  List<Map<String, dynamic>> rowData = [];
  List<bool> isRowFilled = [false];

  List<Person> personsList = [];

  void clearAllRows() {
    setState(() {
      rowData.clear();
      for (var rowControllers in controllers) {
        for (var controller in rowControllers) {
          controller.clear();
        }
      }
    });
  }
  void removeRow(int rowIndex) {
    setState(() {
      controllers.removeAt(rowIndex); // Remove the controllers for the row
      rowData.removeAt(rowIndex); // Remove the data for the row
    });
  }
  void addRow() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];

      for (int j = 0; j < 4; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
      }

      controllers.add(rowControllers);
      isRowFilled.add(false);

      Map<String, dynamic> row = {
        'prodCode': '',
        'prodName': '',
        'unit':'',
        'qty': '',
      };

      rowData.add(row);

      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
  }
  void showWarningMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert box
              },
            ),
          ],
        );
      },
    );
  }
  
  @override
  void initState() {
    super.initState();
    addRow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFF3E0),
        appBar: AppBar(
        title: const Text('Trip Budget'),
          backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white70,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 50,width: 150,
                    child: TextField(
                      controller: _tripNameController,
                      decoration:  InputDecoration(
                          labelText: 'Trip Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10,),
                          )
                      ),
                    ),
                  ),
                  const SizedBox(width: 20,),
                  SizedBox(
                    height: 50,width: 150,
                    child: TextField(
                      controller: _sourceController,
                      decoration:  InputDecoration(
                          labelText: 'Source',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10,),
                          )
                      ),
                    ),
                  ),
                ],
              ),
          
              const SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(
                    height: 50,width: 150,
                    child: Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
          
                          decoration:  InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'From Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10,),
                            ),
                          ),
                          child: Text(
                            _fromDate != null
                                ? '${_fromDate!.toLocal()}'.split(' ')[0]
                                : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 50,width: 150,
                    child: Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration:  InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'To Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10,),
                            ),
                          ),
                          child: Text(
                            _toDate != null
                                ? '${_toDate!.toLocal()}'.split(' ')[0]
                                : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(
                    height: 50,width: 150,
                    child: TextField(
                      controller: _numberOfPersonsController,
                      decoration:  InputDecoration(
                          labelText: 'No of Person',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10,),
                          )
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showAddPersonDialog();
                    },
                    child: Text('Add Person'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Visibility(
                visible: personsList.isNotEmpty,
                child: const Text(
                  'Persons:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Visibility(
                visible: personsList.isNotEmpty,
                child: Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: personsList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Name: ${personsList[index].name}, Age: ${personsList[index].age}, Amount: ${personsList[index].amount}'),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
          
              SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.black54),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FixedColumnWidth(100),
                    1: FixedColumnWidth(100),
                    2: FixedColumnWidth(100),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // Table header row
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            color: Colors.teal,
                            child: const Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 8),
                                  Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            color: Colors.teal,
                            child: const Column(
                              children: [
                                SizedBox(height: 8),
                                Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            color: Colors.teal,
                            child: const Column(
                              children: [
                                SizedBox(height: 8),
                                Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Table data rows
                    for (var i = 0; i < controllers.length; i++)
                      TableRow(
                        children: [
                          for (var j = 0; j < 2; j++)
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  style: TextStyle(fontSize: 13),
                                  controller: controllers[i][j],
                                  inputFormatters: const [

                                  ],
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  onChanged: (value) {

                                  },
                                ),
                              ),
                            ),
                          TableCell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  color: Colors.red.shade600,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirmation'),
                                          content: Text('Are you sure you want to remove this row?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the alert box
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Remove'),
                                              onPressed: () {
                                                if (controllers.length == 1) {
                                                  // If there is only one row, clear the data instead of removing the row
                                                  clearAllRows();
                                                  Navigator.of(context).pop();
                                                } else {
                                                  // If there are multiple rows, remove the entire row
                                                  removeRow(i);
                                                  Navigator.of(context).pop();
                                                }
                                                //Navigator.of(context).pop(); // Close the alert box// Close the alert box
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                Visibility(
                                  visible: i == controllers.length - 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                        onPressed: () {

                                          if (controllers[i][0].text.isNotEmpty && controllers[i][1].text.isNotEmpty ) {
                                            addRow();
                                          } else {
                                            showWarningMessage(' Fields cannot be empty!');
                                          }
                                        },
                                      )

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = selectedDate;
        } else {
          _toDate = selectedDate;
        }
      });
    }
  }

  void _showAddPersonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _nameController = TextEditingController();
        TextEditingController _ageController = TextEditingController();
        TextEditingController _amountController = TextEditingController();

        return AlertDialog(
          title: Text('Add Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  personsList.add(
                    Person(
                      name: _nameController.text,
                      age: int.tryParse(_ageController.text) ?? 0,
                      amount: double.tryParse(_amountController.text) ?? 0.0,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class Person {
  final String name;
  final int age;
  final double amount;

  Person({required this.name, required this.age, required this.amount});
}

