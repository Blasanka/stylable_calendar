library stylable_calendar;

import 'dart:async';

import 'package:dart_days/dart_days.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stylable_calendar/page_dragger.dart';

class StylableCalendar extends StatefulWidget {
  final List<int> specialDays;
  final List<int> highlightedDays;
  final bool isLoading;
  final ValueChanged<DateTime> selectedDate;
  final ValueChanged<DateTime> onNext;
  final ValueChanged<DateTime> onPrevious;

  final Color primaryColor;
  final Color primaryColorDark;
  final Color secondaryColor;

  final bool isPreviousActive;
  final bool isNextActive;

  StylableCalendar({
    this.selectedDate,
    this.specialDays,
    this.isLoading, // if needed to animate after some task
    this.highlightedDays,
    this.onNext,
    this.onPrevious,
    this.primaryColor = Colors.black54,
    this.primaryColorDark = Colors.black,
    this.secondaryColor = Colors.white,
    this.isPreviousActive = false,
    this.isNextActive = false,
  });

  @override
  _StylableCalendarState createState() => _StylableCalendarState();
}

class _StylableCalendarState extends State<StylableCalendar>
    with TickerProviderStateMixin {

  int currentYear;
  int selected;
  int currentMonth;
  int currentMonthDayCount;

  bool isCollapsed = false;

  AnimationController _scaleController;
  Animation _animation;

  Animation<Offset> _animationOpposite;

  bool isPrevious = false;

  StreamController<SlideUpdate> slideUpdateStream;
  AnimatedPageDragger animatedPageDragger;

  SlideDirection slideDirection = SlideDirection.none;
  double slidePercent = 0.0;

  SlideUpdate slideUpdate = SlideUpdate(UpdateType.doneDragging, SlideDirection.none, 0.0);

  _StylableCalendarState() {
    slideUpdateStream = new StreamController<SlideUpdate>();
    slideUpdateStream.stream.listen(slideUpdateListener);
  }

  void slideUpdateListener(SlideUpdate event) {
    setState(() {
      slideUpdate = event;
      if (event.updateType == UpdateType.dragging) {
        slideDirection = event.direction;
        slidePercent = event.slidePercent;

      } else if (event.updateType == UpdateType.doneDragging) {

        if (slideDirection == SlideDirection.leftToRight) {
          decideTransitionEnd(whenPreviousButtonPressed);
        } else if (slideDirection == SlideDirection.rightToLeft) {
          decideTransitionEnd(whenNextButtonPressed);
        } else {/* nothing for now */}

        animatedPageDragger.run();
      } else if (event.updateType == UpdateType.animating) {
        slideDirection = event.direction;
        slidePercent = event.slidePercent;
      } else if (event.updateType == UpdateType.doneAnimating) {
        slideDirection = SlideDirection.none;
        slidePercent = 0.0;

        animatedPageDragger.dispose();
      }
    });
  }

  void decideTransitionEnd(function) {
    if (slidePercent > 0.5) {
      getAnimateDraggerInstance(TransitionGoal.open);
      function();
    } else {
      getAnimateDraggerInstance(TransitionGoal.close);
    }
  }

  void getAnimateDraggerInstance(TransitionGoal goal) {
    animatedPageDragger = new AnimatedPageDragger(
      slideDirection: slideDirection,
      transitionGoal: goal,
      slidePercent: slidePercent,
      slideUpdateStream: slideUpdateStream,
      vsync: this,
    );
  }

  @override
  void initState() {

    DateTime date = DateTime.now();
    selected = date.day;
    currentYear = date.year;
    currentMonth = date.month;
    currentMonthDayCount = DartDays.numberOfDaysInThisMonth();

    _scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _animation = Tween<Offset>(begin: Offset(-.1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );
    _animationOpposite =
        Tween<Offset>(begin: Offset(.1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );
    _scaleController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _scaleController = null;
    _animation = null;
    _animationOpposite = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageDragger(
      canDragLeftToRight: true,
      canDragRightToLeft: true,
      slideUpdateStream: this.slideUpdateStream,
      child: Column(
        children: <Widget>[
          buildCalendarHeader(),
          buildCalendarLabelsHeader(),
          buildCalendarBody(),
        ],
      ),
    );
  }

  Container buildCalendarLabelsHeader() {
    return Container(
      color: widget.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: SlideTransition(
        position: isPrevious ? _animationOpposite : _animation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: DartDays.daysNameOfWeek(numOfChars: 3, sundayFirst: true)
              .map((f) => buildDayNameHolder(f))
              .toList(),
        ),
      ),
    );
  }

  SizedBox buildCalendarBody() {
    int numberOfDaysInMonth =
        DartDays.numberOfDaysForDate(DateTime(currentYear, currentMonth, 1));
    int weekDayOfFirstDayOfMonth = DartDays.weekDayOfFirstDayOfMonth(
        year: currentYear, month: currentMonth);
    int nextMonthDay = numberOfDaysInMonth + weekDayOfFirstDayOfMonth;

    double gridSize;

    if (MediaQuery.of(context).size.width < 600) {
      if ((DartDays.nameOfTheWeekDay(DateTime(currentYear, currentMonth, numberOfDaysInMonth).weekday) == "Saturday")) {
        gridSize = 274;
      } else if (((weekDayOfFirstDayOfMonth != 7) &&
          weekDayOfFirstDayOfMonth > 4 &&
          numberOfDaysInMonth >= 30)) {
        gridSize = 328;
      } else {
        gridSize = 274;
      }
    } else {
      if ((DartDays.nameOfTheWeekDay(DateTime(currentYear, currentMonth, numberOfDaysInMonth).weekday) == "Saturday")) {
        gridSize = 556;
      } else if (((weekDayOfFirstDayOfMonth != 7) &&
          weekDayOfFirstDayOfMonth > 4 &&
          numberOfDaysInMonth >= 30)) {
        gridSize = 658;
      } else {
        gridSize = 556;
      }
    }

    return SizedBox(
      height: isCollapsed
          ? (MediaQuery.of(context).size.width < 600) ? 62 : 138
          : gridSize + 16,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack(
          children: <Widget>[
            SizedBox.fromSize(
              size: Size(
                  double.infinity,
                  isCollapsed
                      ? (MediaQuery.of(context).size.width < 600) ? 52 : 112
                      : gridSize), //272
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                color: widget.primaryColor,
                child: SlideTransition(
                  position: isPrevious ? _animationOpposite : _animation,
                  child: GridView.count(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    crossAxisCount: 7,
                    physics: new NeverScrollableScrollPhysics(),
                    children: List.generate(
                      isCollapsed ? 7 : 45,
                      (int index) {
                        if (!isCollapsed)
                          return buildExpandedHolderView(
                              index,
                              weekDayOfFirstDayOfMonth,
                              numberOfDaysInMonth,
                              nextMonthDay);
                        else
                          return buildAnimatedDayHolder(
                              (numberOfDaysInMonth == selected && index == 6)
                                  ? index - 5
                                  : (selected > 5)
                                      ? selected - 5 + index
                                      : index + 1);
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: isCollapsed ? -4 : 0,
              right: 5,
              child: InkWell(
                onTap: () {
                  setState(() {
                    isCollapsed = !isCollapsed;
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  margin: EdgeInsets.only(top: 5, bottom: 4, left: 8, right: 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      stops: [0, 1],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.primaryColorDark.withOpacity(.8),
                        widget.primaryColor.withOpacity(.9),
                      ],
                    ),
                  ),
                  child: Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: widget.secondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedDayHolder buildExpandedHolderView(int index,
      int weekDayOfFirstDayOfMonth, int numberOfDaysInMonth, int nextMonthDay) {
    int day = index + 1;
    int displayingDay =
    (weekDayOfFirstDayOfMonth < 7) ? day - weekDayOfFirstDayOfMonth : day;

    if ((weekDayOfFirstDayOfMonth == 7) && (numberOfDaysInMonth+1) == day) {
      int previousMonthDay = 1;
      return buildDisabledDayHolder(previousMonthDay);
    } else if ((weekDayOfFirstDayOfMonth < 7) && day <= weekDayOfFirstDayOfMonth) {
      int previousMonthDayCount = DartDays.numberOfDaysForDate(
          DateTime(currentYear, currentMonth - 1, 1));
      int previousMonthDay =
          day + (previousMonthDayCount - weekDayOfFirstDayOfMonth);
      return buildDisabledDayHolder(previousMonthDay);
    } else if ((displayingDay > 31) && weekDayOfFirstDayOfMonth == 7) {
      return buildDisabledDayHolder((day == 30)
          ? day
          : (displayingDay == 31) ? day : day - numberOfDaysInMonth);
    } else if (day > nextMonthDay) {
      return buildDisabledDayHolder(day - nextMonthDay);
    } else
      return buildAnimatedDayHolder(displayingDay);
  }

  AnimatedDayHolder buildAnimatedDayHolder(int displayingDay) {
    return AnimatedDayHolder(
      onTap: () {
        setState(() => selected = displayingDay);
        widget.selectedDate(DateTime(currentYear, currentMonth, selected));
      },
      day: displayingDay,
      specialDays: widget.specialDays,
      highlightedDays: widget.highlightedDays,
      isSelected: displayingDay == selected,
      isLoading: widget.isLoading,
      primaryColor: widget.primaryColor,
      secondaryColor: widget.secondaryColor,
    );
  }

  AnimatedDayHolder buildDisabledDayHolder(int monthDay) {
    return AnimatedDayHolder(
      onTap: () {},
      day: monthDay,
      specialDays: [],
      highlightedDays: [],
      isSelected: false,
      isSelectable: false,
      primaryColor: widget.primaryColor,
      secondaryColor: widget.secondaryColor,
    );
  }

  Container buildCalendarHeader() {
    return Container(
      color: widget.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: widget.isPreviousActive ? widget.secondaryColor : Color(0xFFd1d1d1),
            ),
            onPressed: widget.isPreviousActive ? whenPreviousButtonPressed : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                "${DartDays.nameOfMonth(currentMonth)}, $currentYear",
                style: GoogleFonts.pTSans(
                  textStyle: TextStyle(
                    color: widget.secondaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: widget.isPreviousActive ? widget.secondaryColor : Color(0xFFd1d1d1),
            ),
            onPressed: widget.isPreviousActive ? whenNextButtonPressed : null,
          ),
        ],
      ),
    );
  }

  void whenPreviousButtonPressed() {
    setState(() {
      isPrevious = true;
      selected = 1;
      --currentMonth;
    });
    if (_scaleController.isCompleted) {
      _scaleController.reset();
      _scaleController.forward();
    }
    if (currentMonth < 1) {
      setState(() {
        --currentYear;
        currentMonth = 12;
      });
    }
    final thisDate = DateTime(currentYear, currentMonth, 1);
    setState(() {
      currentMonthDayCount = DartDays.numberOfDaysForDate(thisDate);
    });

    widget.onPrevious(thisDate);
  }

  void whenNextButtonPressed() {
    setState(() {
      isPrevious = false;
      ++currentMonth;
      selected = 1;
    });
    if (_scaleController.isCompleted) {
      _scaleController.reset();
      _scaleController.forward();
    }
    if (currentMonth > 12)
      setState(() {
        ++currentYear;
        currentMonth = 1;
      });

    final thisDate = DateTime(currentYear, currentMonth, 1);
    setState(() {
      currentMonthDayCount = DartDays.numberOfDaysForDate(thisDate);
    });
    widget.onNext(thisDate);
  }

  Widget buildDayNameHolder(String f) {
    return Container(
      width: 38,
      height: 20,
      child: Center(
        child: Text(
          f,
          style: GoogleFonts.pTSans(
            textStyle: TextStyle(
              fontSize: 16,
              color: widget.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedDayHolder extends StatefulWidget {
  final GestureTapCallback onTap;
  final int day;
  final List<int> specialDays;
  final List<int> highlightedDays;
  final bool isSelected;
  final bool isSelectable;
  final bool isLoading;
  final Color primaryColor;
  final Color secondaryColor;

  AnimatedDayHolder({
    Key key,
    this.onTap,
    this.day,
    this.specialDays,
    this.highlightedDays,
    this.isSelected,
    this.isSelectable = true,
    this.isLoading = false,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  _AnimatedDayHolderState createState() => _AnimatedDayHolderState();
}

class _AnimatedDayHolderState extends State<AnimatedDayHolder>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Color holderColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildDayHolder(context, widget.day);
  }

  InkWell buildDayHolder(BuildContext context, int day) {
    holderColor = widget.isSelectable
        ? widget.secondaryColor
        : Color(0xFFd1d1d1);
    return InkWell(
      onTap: () {
        widget.onTap();
        if (!_controller.isCompleted)
          _controller.forward();
        else {
          _controller.reset();
          _controller.forward();
        }
      },
      child: ScaleTransition(
        scale: Tween(begin: 0.96, end: 1.14).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        )),
        child: buildHolder(day, context),
      ),
    );
  }

  Padding buildHolder(int day, BuildContext context) {
    return Padding(
      key: Key(day.toString()),
      padding: EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          border: widget.specialDays.contains(day)
              ? Border.all(width: 1, color: holderColor)
              : null,
          shape: BoxShape.circle,
          color: widget.isSelected ? holderColor : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            widget.highlightedDays.contains(day) ? buildDot() : SizedBox(),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: GoogleFonts.pTSans(
                    textStyle: TextStyle(
                      color:
                          widget.isSelected
                              ? widget.primaryColor
                              : holderColor,
                      fontSize: 18,
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

  Widget buildDot() => widget.isSelected
      ? SizedBox()
      : AnimatedOpacity(
          opacity: widget.isLoading ? 0.0 : 1.0,
          duration: Duration(milliseconds: 1000),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: holderColor,
              shape: BoxShape.circle,
            ),
          ),
        );
}
