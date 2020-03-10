# example

Example for Horizontal stylable_calendar


#### Example One (Basic / Default):

```
import 'package:flutter/material.dart';
import 'package:stylable_calendar/stylable_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SO answers sample snippet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DateIndicatorPage(),
    );
  }
}

class DateIndicatorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            DateIndicator(),
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
```

Go to example directory to see demo app with how to change colors:
https://github.com/Blasanka/stylable_calendar/tree/master/example

#### Example two with holder tap action

```
import 'package:flutter/material.dart';
import 'package:stylable_calendar/stylable_calendar.dart';

class DateIndicatorPage extends StatefulWidget {

  @override
  _DateIndicatorPageState createState() => _DateIndicatorPageState();
}

class _DateIndicatorPageState extends State<DateIndicatorPage> {
  int selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 68),
          child: DateIndicator(
            onHolderTap: (int day) => setState(() => selectedDay = day),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Center(child: Text("$selectedDay")),
            ),
          ),
        ],
      ),
    );
  }
}
```

Contributor are welcome. Or if you encounter any bug, please mail to blasanka95@yahoo.com


## Just started with Flutter?

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
