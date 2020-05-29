library stylable_calendar;

import 'package:flutter/material.dart';
import 'package:stylable_calendar/on_screen_month_view.dart';

enum CalendarViewType {
  onScreenMonth,
  onScreenWeek,
  popUpCalendar,
  dropDownCalendar,
  dialogCalendar,
  bottomSheetCalendar,
}

class StylableCalendar extends StatefulWidget {
  final CalendarViewType calendarViewType;
  final List<int> specialDays;
  final List<int> highlightedDays;
  final bool isLoading;
  final bool isCollapsed;
  final ValueChanged<DateTime> selectedDate;
  final ValueChanged<DateTime> onNext;
  final ValueChanged<DateTime> onPrevious;

  final TextStyle headerTextStyle;
  final TextStyle dayTextStyle;
  final TextStyle dayNameTextStyle;

  final Color primaryColor;
  final Color primaryColorDark;
  final Color secondaryColor;
  final Color selectedDayColor;

  final bool isPreviousActive;

  StylableCalendar({
    this.calendarViewType = CalendarViewType.onScreenMonth,
    this.selectedDate,
    this.specialDays,
    this.highlightedDays,
    this.isLoading, // if needed to animate after some task
    this.onNext,
    this.onPrevious,
    this.primaryColor = Colors.black54,
    this.primaryColorDark = Colors.black,
    this.secondaryColor = Colors.white,
    this.selectedDayColor,
    this.isCollapsed = false,
    this.isPreviousActive = false,
    this.isNextActive = false,
    this.headerTextStyle,
    this.dayTextStyle,
    this.dayNameTextStyle,
  });

  final bool isNextActive;

  @override
  _StylableCalendarState createState() => _StylableCalendarState();
}

class _StylableCalendarState extends State<StylableCalendar> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.calendarViewType) {

      case CalendarViewType.onScreenWeek:
        return SizedBox();
      case CalendarViewType.popUpCalendar:
        return SizedBox();
      case CalendarViewType.dropDownCalendar:
        return SizedBox();
      case CalendarViewType.dialogCalendar:
        return SizedBox();
      case CalendarViewType.bottomSheetCalendar:
        return SizedBox();
      case CalendarViewType.onScreenMonth:
      default:
        return OnScreenMonthView(
          selectedDate: widget.selectedDate,
          specialDays: widget.specialDays,
          highlightedDays: widget.highlightedDays,
          isLoading: widget.isLoading,
          onNext: widget.onNext,
          onPrevious: widget.onPrevious,
          primaryColor: widget.primaryColor,
          primaryColorDark: widget.primaryColorDark,
          secondaryColor: widget.secondaryColor,
          selectedDayColor: widget.selectedDayColor,
          isCollapsed: widget.isCollapsed,
          isPreviousActive: widget.isPreviousActive,
          isNextActive: widget.isNextActive,
          headerTextStyle: widget.headerTextStyle,
          dayTextStyle: widget.dayTextStyle,
          dayNameTextStyle: widget.dayNameTextStyle,
        );
    }
  }

}
