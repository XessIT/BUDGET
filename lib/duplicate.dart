import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('SingleChildScrollView Example'),
        ),
        body: Column(
          children: <Widget>[
            Container(
              height: 200.0,
              color: Colors.blue,
              child: Center(
                child: Text(
                  'Header Content',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
            Container(
              height: 1000.0, // This container's height exceeds the screen height.
              color: Colors.green,
              child: Center(
                child: Text(
                  'Scrollable Content',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
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