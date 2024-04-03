import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mybudget/DashBoard.dart';
import 'package:mybudget/signup.dart';

import 'check_date.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController mobile = TextEditingController();
  TextEditingController otpcontroller = TextEditingController();
  String? getID = "";
  String checkOTP = '';
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  bool _timerRunning = false;
  int _timerCountdown = 60; // Timer countdown duration in seconds
  late Timer _timer;

  String generateOTP() {
    Random random = Random();
    int otp = random.nextInt(900000) + 100000;
    return otp.toString();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   title: Text(
      //     "Sign In",
      //     style: Theme.of(context).textTheme.titleLarge,
      //   ),
      // ),
      extendBodyBehindAppBar: true,
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8155BA), Color(0xFFB667DF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28, // Adjust the font size as needed
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xFFB667DF),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            60.0), // adjust the radius as needed
                      ),
                      child: Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              top: 195,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60.0), // adjust the radius as needed
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                      decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                    ),
                    color: Color(0xFF8155BA).withOpacity(0.4),
                  )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 230, left: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        // Timer display

                        SizedBox(height: 20),

                        // Resend OTP button
                        /*   if (!_timerRunning)
                          ElevatedButton(
                            onPressed: () {
                              //   String newOtp = generateOTP();
                              //   print("OTP-- $newOtp");
                              setState(() {
                                //   checkOTP = newOtp;
                                _timerCountdown = 60; // Reset timer countdown
                                _timerRunning = true; // Start the timer
                              });
                              startTimer(); // Start the timer countdown
                              updatedetails();
                              // Your existing SMS sending code
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF8155BA),
                            ),
                            child: Text(
                              "Resend OTP",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),*/
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                            controller: mobile,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.black),
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
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                              prefix: Text("+91"),
                              prefixStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                            ),
                            onChanged: (value) {
                              setState(() {
                                getData(value);
                              });
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: TextFormField(
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
                                    ?.copyWith(color: Colors.black)),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                            ],
                          ),
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
                                  String sms =
                                      "Welcome to GiB,Your OTP is $otp";
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
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
                        if (_timerRunning)
                          Text(
                            'OTP Timer: $_timerCountdown seconds',
                            style: TextStyle(color: Colors.black),
                          ),
                        // Error message for invalid OTP
                        if (!_timerRunning && otpcontroller.text.isNotEmpty)
                          Text(
                            'Invalid OTP. Please try again or resend OTP.',
                            style: TextStyle(color: Colors.red),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (otpcontroller.text == checkOTP) {
                              // OTP matches, navigate to the home page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SamDate()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Invalid OTP. Please try again.")));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            backgroundColor: Color(0xFF8155BA),
                          ),
                          child: Text(
                            "Login",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //  crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an Account?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Signup(title: "")),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
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
