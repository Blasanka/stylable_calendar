import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stylable_calendar/stylable_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Stylable Calendar example",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo"),
      ),
      body: ListView(
        children: <Widget>[
          StylableCalendar(
            specialDays: [20, 13, 6, 10],
            highlightedDays: [1, 4, 5],
//            primaryColor: Theme.of(context).primaryColor,
//            primaryColorDark: Theme.of(context).primaryColorDark,
//            secondaryColor: Theme.of(context).primaryColorLight,
//            headerTextStyle: GoogleFonts.pTSans(
//              textStyle: TextStyle(
//                color: Colors.red,
//                fontSize: 18,
//              ),
//            ),
//            dayTextStyle: TextStyle(
//              color: Colors.lightGreen,
//              fontSize: 18,
//            ),
//            dayNameTextStyle: TextStyle(
//              fontSize: 16,
//              color: Colors.orangeAccent,
//            ),
            // in this case to animate highlighted dots
            selectedDate: (DateTime date) {
              print(date);
            },
            onNext: (DateTime date) {
              print(date);
            },
            onPrevious: (DateTime date) {
              print(date);
            },
          ),
        ],
      ),
    );
  }
}
