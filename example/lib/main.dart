import 'package:flutter/material.dart';
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
            primaryColor: Colors.white.withAlpha(100),
            primaryColorDark: Colors.white,
            secondaryColor: Theme.of(context).primaryColor,
            selectedDayColor: Colors.white,
            isCollapsed: true,
            isNextActive: true,
            isPreviousActive: true,
            selectedDate: (DateTime date) {
              return;
            },
            onNext: (DateTime date) async {
              return;
            },
            onPrevious: (DateTime date) async {
              return;
            },
          ),
//          StylableCalendar(
//            specialDays: [20, 13, 6, 10],
//            highlightedDays: [1, 4, 5],
//            isNextActive: true,
//            isPreviousActive: true,
//            isCollapsed: true,
////            primaryColor: Theme.of(context).primaryColor,
////            primaryColorDark: Theme.of(context).primaryColorDark,
////            secondaryColor: Theme.of(context).primaryColorLight,
////            headerTextStyle: GoogleFonts.pTSans(
////              textStyle: TextStyle(
////                color: Colors.red,
////                fontSize: 18,
////              ),
////            ),
//            dayTextStyle: TextStyle(
//              color: Colors.lightGreen,
//              fontSize: 18,
//            ),
////            dayNameTextStyle: TextStyle(
////              fontSize: 16,
////              color: Colors.orangeAccent,
////            ),
//            // in this case to animate highlighted dots
//            selectedDate: (DateTime date) {
//              print(date);
//            },
//            onNext: (DateTime date) {
//              print(date);
//            },
//            onPrevious: (DateTime date) {
//              print(date);
//            },
//          ),
        ],
      ),
    );
  }
}
