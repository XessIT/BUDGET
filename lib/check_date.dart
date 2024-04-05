import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SamDate extends StatefulWidget {
  const SamDate({super.key});

  @override
  State<SamDate> createState() => _SamDateState();
}

class _SamDateState extends State<SamDate> {

  late DateTime fromDate;
  late DateTime toDate;
  DateTime date =DateTime.now();
  final TextEditingController Fromdate = TextEditingController();
  final TextEditingController Todate = TextEditingController();
  TextEditingController monthlyincome = TextEditingController();
  TextEditingController monthlyincomeType = TextEditingController();

  Future<void> insertMonthlyData2()async {
    try{
      final url=Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/MonthlyDashBoard.php');
      final DateTime fromparsedDate = DateFormat('dd-MM-yyyy').parse(Fromdate.text);
      final fromDate = DateFormat('yyyy-MM-dd').format(fromparsedDate);
      final DateTime toparsedDate = DateFormat('dd-MM-yyyy').parse(Todate.text);
      final toDate = DateFormat('yyyy-MM-dd').format(toparsedDate);
      print("Url: $url");
      final response = await http.post(
        url,
        body: jsonEncode({
          "uid": "5",
          "incomeType": monthlyincomeType.text,
          "incomeAmt": monthlyincome.text,
          "fromDate": fromDate,
          "toDate": toDate,
          "status":"open",
        }),
      );

      if (response.statusCode == 200) {
        print("Trip added successfully!");
        print("Response body: ${response.body}");
        print("Response Status: ${response.statusCode}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    }
    catch (e){
      print("Error during trip addition: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: Fromdate,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "*Enter the Validity";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'From Date',
                  suffixIcon: IconButton(
                    onPressed: () async {
                      DateTime? pickDate = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      print("Picked date: $pickDate");
                      if (pickDate != null) {
                        setState(() {
                          Fromdate.text = DateFormat('dd-MM-yyyy').format(pickDate);
                          print("_date.text updated: ${Fromdate.text}");

                          int daysInCurrentMonth = DateTime(pickDate.year, pickDate.month + 1, 0).day;
                          int daysToAdd;

                          switch (pickDate.month) {
                            case DateTime.february:
                              bool isLeapYear = pickDate.year % 4 == 0 && (pickDate.year % 100 != 0 || pickDate.year % 400 == 0);
                              daysToAdd = isLeapYear ? 29 : 28;
                              break;
                            case DateTime.april:
                            case DateTime.june:
                            case DateTime.september:
                            case DateTime.november:
                              daysToAdd = 30;
                              break;
                            default:
                              daysToAdd = 31;
                          }
                          if (pickDate.day == 1) {
                            toDate = pickDate.add(Duration(days: daysToAdd - 1));
                          } else {
                            toDate = pickDate.add(Duration(days: daysToAdd - 1));
                          }

                          Todate.text = DateFormat('dd-MM-yyyy').format(toDate);
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    color: Colors.green,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: Todate,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "*Enter the Validity";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'To Date',
                  suffixIcon: IconButton(
                    onPressed: () async {
                      DateTime? pickDate = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      print("Picked date: $pickDate");
                      if (pickDate != null) {
                        setState(() {
                          Todate.text = DateFormat('dd-MM-yyyy').format(pickDate);
                          print("_date.text updated: ${Todate.text}");
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    color: Colors.green,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 70,
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: monthlyincomeType,
                    decoration: InputDecoration(
                      // filled: true,
                      // fillColor: Colors.white,
                      hintText: 'Income Type',
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Allow only alphabets
                    ],
                  //  validator: (value) => _validateFormField(value, 'Income Type'),
                    onChanged: (value) {
                      setState(() {
                      //  _monthlyincomeTypeError = null; // Clear error message when text changes
                      });
                    },
                  ),
                  /*if (_monthlyincomeTypeError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        _monthlyincomeTypeError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),*/
                  // Add other form fields and error messages here
                ],
              ),
            ),
            SizedBox(height: 2),
            SizedBox(
              height: 70,
              width: 250,
              child: Column(
                children: [
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: monthlyincome,
                    decoration: InputDecoration(
                      // filled: true,
                      // fillColor: Colors.white,
                      hintText: 'Income Amount',
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  //  validator: (value) => _validateFormField(value, 'Income Amount'),
                    onChanged: (value) {
                      setState(() {
                       // _monthlyincomeAmountError = null; // Clear error message when text changes
                      });
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(7)
                    ],
                  ),

                ],
              ),
            ),
            /*SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Validate the form
                if (_formKey.currentState!.validate()) {
                  // All fields are valid, proceed with your logic
                  if (monthlyincomeType.text.isEmpty) {
                    // Set error message for monthlyincomeType
                    setState(() {
                      _monthlyincomeTypeError = 'Income Type is required.';
                    });

                  }
                  else  if (monthlyincome.text.isEmpty) {
                    // Set error message for monthlyincomeType
                    setState(() {
                      _monthlyincomeAmountError = 'Income Amount is required.';
                    });

                  }
                  else {

                    insertMonthlyData2();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonthlyDashboard(uid: '',),
                      ),
                    );
                  }
                } else {
                  // Fields are not valid, trigger a rebuild to display error messages
                  setState(() {});
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
              ),
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),*/
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Validate the form
                  // All fields are valid, proceed with your logic
                    insertMonthlyData2();
                    /*Navigator.push(context, MaterialPageRoute(
                        builder: (context) => MonthlyDashboard(uid: '',),),);*/
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
              ),
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),
          ]
        )
      )
    );
  }
}
