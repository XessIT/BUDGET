import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mybudget/DashBoard.dart';
import 'login.dart';
import 'main.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController name = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController companyName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController otpcontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  String? getID = "";
  String checkOTP = '';

  bool _otpSent = false;
  bool _timerRunning = false;
  int _timerCountdown = 60; // Timer countdown duration in seconds
  late Timer _timer;

  Future<void> signupInsert() async {
    try {
      final url =
          Uri.parse('http://localhost/Mybudget/lib/BUDGETAPI/signup.php');
      final response = await http.post(
        url,
        body: jsonEncode({
          "user_name": name.text.trim(),
          "mobile": mobile.text.trim(),
          "company_name": companyName.text.trim(),
          "address": address.text.trim(),
          "otp": otpcontroller.text.trim()
        }),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup is Successful")),
        );
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during signup: $e");
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerCountdown > 0) {
        setState(() {
          _timerCountdown--;
        });
      } else {
        _timer.cancel();
        setState(() {
          _timerRunning = false;
        });
      }
    });
    // Force UI update after starting the timer
    setState(() {});
  }

  List<Map<String, dynamic>> data = [];
  Future<void> getData(String mobile) async {
    if (_otpSent) {
      print('Attempting to make HTTP request...');

      try {
        final url = Uri.parse(
            'http://localhost/Mybudget/lib/BUDGETAPI/signup.php?mobile=$mobile');
        print("get - $url");
        final response = await http.get(url);
        print("get Response Status: ${response.statusCode}");
        print("getResponse: ${response.body}");
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print("ResponseData: $responseData");
          if (responseData is List) {
            // If responseData is a List (multiple records)
            final List<dynamic> itemGroups = responseData;
            setState(() {
              data = itemGroups.cast<Map<String, dynamic>>();
            });
            print('get Data: $data');
          } else if (responseData is Map<String, dynamic>) {
            // If responseData is a Map (single record)
            setState(() {
              data = [responseData];
            });
            print('get Data: $data');
          }
        } else {
          print('Error: ${response.statusCode}');
        }
        print('HTTP request completed. Status code: ${response.statusCode}');
      } catch (e) {
        print('Error making HTTP request: $e');
        throw e;
      }
    }
  }

  Future<void> updatedetails() async {
    try {
      final url =
          Uri.parse('http://localhost/Mybudget/lib/BUDGETAPI/signup.php');
      print("edit url:$url");

      final response = await http.put(
        url,
        body: jsonEncode({
          'id': data[0]["id"],
          'otp': checkOTP.toString(),
          'datetime': DateTime.now().toString(), // Convert datetime to string
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print("edit body:${response.body}");

      if (response.statusCode == 200) {
        print("edit status code:${response.statusCode}");
        print("edit check body:${response.body}");

        print('OTP updated successfully');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => PersonalEdit(currentID: widget.currentID,)),
        // );
      } else {
        // Error handling, e.g., show an error message
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or server errors
      print('Error making HTTP request: $e');
    }
  }

  String generateOTP() {
    Random random = Random();
    int otp = random.nextInt(900000) + 100000;
    return otp.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF8155BA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF8155BA),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Sign Up",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.white, // Set the background color to white
              ),
            ),
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 30),
                      TextFormField(
                        controller: name,
                        onChanged: (value) {
                          String capitalizedValue =
                              capitalizeFirstLetter(value);
                          name.value = name.value.copyWith(
                            text: capitalizedValue,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '* Enter your Name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: mobile,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '* Enter your Mobile Number';
                          } else if (value.length < 10) {
                            return "* Mobile should be 10 digits";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Mobile",
                          prefix: Text("+91"),
                          prefixStyle: TextStyle(color: Colors.purple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 100,
                        controller: address,
                        onChanged: (value) {
                          String capitalizedValue =
                              capitalizeFirstLetter(value);
                          address.value = address.value.copyWith(
                            text: capitalizedValue,
                          );
                        },
                        decoration: InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: otpcontroller,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.black),
                        /*validator: (value) {
                            if (value!.isEmpty) {
                              return '* Enter your OTP';
                            } else if (value.length < 10) {
                              return "* OTP should be 6 digits";
                            }
                            return null;
                          },*/
                        decoration: InputDecoration(
                          labelText: "OTP",
                          labelStyle: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: TextButton(
                            onPressed: () async {
                              String newOtp = generateOTP();
                              print("OTP-- $newOtp");
                              setState(() {
                                checkOTP = newOtp;
                                // St
                              });
                              updatedetails();
                              String welcomeText = "Welcome To Budget,";
                              String otp = checkOTP;

                              print(otp);

                              if (_formKey.currentState!.validate()) {
                                //  startTimer(); // Start the timer countdown
                                String apikey =
                                    "5YCbYiCLPF-G5q9CdsjexCtIzxCJHsk4mHJAp5CoCCgPljMAM8Eb-kH8VEZuUdo7"; // Replace with your actual API key
                                String senderid = "GIBOTP";
                                String? number = mobile.text;
                                String sms = "Welcome to GiB,Your OTP is $otp";
                                String templateid =
                                    "1207161941423943558"; // Replace with your actual template ID

                                final encodedSms = Uri.encodeComponent(sms);
                                final url = Uri.parse(
                                    "https://obligr.io/api_v2/message/send?api_key=$apikey&dlt_template_id=$templateid&sender_id=$senderid&mobile_no=$number&message=$encodedSms&unicode=0");

                                try {
                                  print(url);
                                  final response = await http.get(url);
                                  if (response.statusCode == 200) {
                                    print('SMS sent successfully');
                                    _otpSent = true;
                                    _timerCountdown =
                                        60; // Reset timer countdown
                                    _timerRunning = true;
                                    startTimer();
                                    updatedetails();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Failed to send SMS. Try Again Later...")));
                                    print('Failed to send SMS');
                                  }
                                } catch (error) {
                                  print('Error sending SMS: $error');
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Mobile Number is Not Registered")));
                              }
                            },
                            child: Text(
                              _otpSent
                                  ? (_timerRunning ? "Resend " : "Resend")
                                  : "Send OTP",
                              style: TextStyle(color: Color(0xFF8155BA)),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  signupInsert();
                                }
                              },
                              child: Text(
                                "Signup",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 10,
                                backgroundColor:
                                    Color(0xFF8155BA), // Set background color
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                if (otpcontroller.text == checkOTP) {
                                  // OTP matches, navigate to the home page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DashBoard()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Invalid OTP. Please try again.")));
                                }
                              },
                              child: Text(
                                "Back",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 10,
                                backgroundColor:
                                    Color(0xFF8155BA), // Set background color
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: 10),
                      //
                      //
                      // SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlphabetInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String filteredText = newValue.text.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    return newValue.copyWith(text: filteredText);
  }
}
