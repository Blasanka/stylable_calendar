library stylable_calendar;

import 'dart:async';

import 'package:dart_days/dart_days.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stylable_calendar/page_dragger.dart';

class OnScreenMonthView extends StatefulWidget {
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

  OnScreenMonthView({
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
  _OnScreenMonthViewState createState() => _OnScreenMonthViewState();
}

class _OnScreenMonthViewState extends State<OnScreenMonthView>
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

  SlideUpdate slideUpdate =
  SlideUpdate(UpdateType.doneDragging, SlideDirection.none, 0.0);

  ScrollController weekListViewController;

  _OnScreenMonthViewState() {
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
        } else {
          /* nothing for now */
        }

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

    weekListViewController = ScrollController();
    isCollapsed = widget.isCollapsed;

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
//    if (isCollapsed) {
//      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
//        weekListViewController.jumpTo(28.0 * selected);
//      });
//    }
    super.initState();
  }

  @override
  void didUpdateWidget(OnScreenMonthView oldWidget) {
    selected = 21;
    if (isCollapsed && selected > 6) {
      weekListViewController.jumpTo(45.0 * selected);
    }
    super.didUpdateWidget(oldWidget);
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
          buildCalendarBody(),
        ],
      ),
    );
  }

  Container buildCalendarLabelsHeader(Widget child) {
    return Container(
      color: !isCollapsed ? widget.primaryColor : null,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SlideTransition(
        position: isPrevious ? _animationOpposite : _animation,
        child: child,
      ),
    );
  }

  Widget buildCalendarBody() {
    int numberOfDaysInMonth =
    DartDays.numberOfDaysForDate(DateTime(currentYear, currentMonth, 1));
    int weekDayOfFirstDayOfMonth = DartDays.weekDayOfFirstDayOfMonth(
        year: currentYear, month: currentMonth);
    int nextMonthDay = numberOfDaysInMonth + weekDayOfFirstDayOfMonth;

    double gridSize;

    Size screenSize = MediaQuery.of(context).size;
    if (screenSize.width <= 500) {
      if ((DartDays.nameOfTheWeekDay(
          DateTime(currentYear, currentMonth, numberOfDaysInMonth)
              .weekday) ==
          "Saturday")) {
        gridSize = screenSize.height / 3; //274;
      } else if ((weekDayOfFirstDayOfMonth > 4 &&
          (weekDayOfFirstDayOfMonth != 7) &&
          numberOfDaysInMonth >= 30)) {
        gridSize = screenSize.height / 2.55; //328;
      } else {
        gridSize = screenSize.height / 3; //274;
      }
    } else {
      if ((DartDays.nameOfTheWeekDay(
          DateTime(currentYear, currentMonth, numberOfDaysInMonth)
              .weekday) ==
          "Saturday")) {
        gridSize = screenSize.width / 1.48; //556;
      } else if (((weekDayOfFirstDayOfMonth != 7) &&
          weekDayOfFirstDayOfMonth > 4 &&
          numberOfDaysInMonth >= 30)) {
        gridSize = screenSize.width / 1.49; //658;
      } else {
        gridSize = screenSize.width / 1.46; // 556;
      }
    }

    if (isCollapsed) {
      double collapsedViewHeight = 86;
      return SizedBox(
        height: collapsedViewHeight,
        child: Stack(
          children: <Widget>[
            SlideTransition(
              position: isPrevious ? _animationOpposite : _animation,
              child: Container(
                color: widget.primaryColor,
                height: collapsedViewHeight - 8,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                child: ListView.builder(
                  controller: weekListViewController,
                  scrollDirection: Axis.horizontal,
                  itemExtent: 52,
                  itemCount: numberOfDaysInMonth,
                  itemBuilder: (BuildContext context, int index) {
                    DateTime dateForDay = DateTime(currentYear, currentMonth, index+1);
                    return Column(
                      children: <Widget>[
                        buildCalendarLabelsHeader(
                          buildDayNameHolder(DateFormat('EEEE').format(dateForDay).substring(0, 3)),
                        ),
                        SizedBox(
                            height: collapsedViewHeight / 1.5,
                            child: buildAnimatedDayHolder(index+1)),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
                bottom: -4,
                right: 5,
                child: buildExpandButton()),
          ],
        ),
      );
    } else {
      return SizedBox(
        height: gridSize + 28,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  buildCalendarLabelsHeader(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: DartDays.daysNameOfWeek(numOfChars: 3, sundayFirst: true)
                          .map((f) => buildDayNameHolder(f))
                          .toList(),
                    ),
                  ),
                  SizedBox.fromSize(
                    size: Size(
                        double.infinity, gridSize), //272
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      color: widget.primaryColor,
                      child: SlideTransition(
                        position: isPrevious ? _animationOpposite : _animation,
                        child: GridView.count(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: 1.15,
                          crossAxisCount: 7,
                          physics: new NeverScrollableScrollPhysics(),
                          children: List.generate(
                            45, (int index) {
                            return buildExpandedHolderView(
                                index,
                                weekDayOfFirstDayOfMonth,
                                numberOfDaysInMonth,
                                nextMonthDay);
                          },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                  bottom: 0,
                  right: 5,
                  child: buildExpandButton()),
            ],
          ),
        ),
      );
    }
  }

  InkWell buildExpandButton() {
    return InkWell(
      onTap: () {
        setState(() {
          isCollapsed = !isCollapsed;
        });
        if (isCollapsed)
          WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
            weekListViewController.jumpTo((MediaQuery.of(context).size.width / 2) * selected);
          });
      },
      child: Container(
        width: 23,
        height: 23,
        margin:
        EdgeInsets.only(top: 5, bottom: 4, left: 8, right: 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            stops: [0, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.primaryColorDark.withOpacity(.5),
              widget.primaryColor.withOpacity(.6),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            !isCollapsed
                ? Icons.keyboard_arrow_down
                : Icons.keyboard_arrow_up,
            color: widget.secondaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  AnimatedDayHolder buildExpandedHolderView(int index,
      int weekDayOfFirstDayOfMonth, int numberOfDaysInMonth, int nextMonthDay) {
    int day = index + 1;
    int displayingDay =
    (weekDayOfFirstDayOfMonth < 7) ? day - weekDayOfFirstDayOfMonth : day;

    if ((weekDayOfFirstDayOfMonth == 7) && (numberOfDaysInMonth + 1) == day) {
      int previousMonthDay = 1;
      return buildDisabledDayHolder(previousMonthDay);
    } else if ((weekDayOfFirstDayOfMonth < 7) &&
        day <= weekDayOfFirstDayOfMonth) {
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
      isLoading: widget.isLoading ?? false,
      primaryColor: widget.primaryColor,
      secondaryColor: widget.secondaryColor,
      dayTextStyle: widget.dayTextStyle,
      selectedDayColor: widget.selectedDayColor,
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
      dayTextStyle: widget.dayTextStyle,
      selectedDayColor: widget.selectedDayColor,
    );
  }

  Container buildCalendarHeader() {
    return Container(
      color: widget.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: widget.isPreviousActive ? whenPreviousButtonPressed : null,
            child: Container(
              width: 32,
              height: 32,
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: widget.isPreviousActive
                    ? widget.secondaryColor
                    : Color(0xFFd1d1d1),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  "${DartDays.nameOfMonth(currentMonth)}, $currentYear",
                  style: (widget.headerTextStyle != null)
                      ? widget.headerTextStyle
                      : TextStyle(
                    color: widget.secondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: widget.isPreviousActive ? whenNextButtonPressed : null,
            child: Container(
              width: 32,
              height: 32,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: widget.isPreviousActive
                    ? widget.secondaryColor
                    : Color(0xFFd1d1d1),
              ),
            ),
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
      height: 18,
      child: Center(
        child: Text(
          f,
          style: (widget.dayNameTextStyle != null)
              ? widget.dayNameTextStyle
              : TextStyle(
            fontSize: 12,
            color: widget.secondaryColor,
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
  final Color selectedDayColor;

  final TextStyle dayTextStyle;

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
    this.selectedDayColor,
    this.dayTextStyle,
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
    holderColor =
    widget.isSelectable ? widget.secondaryColor : Color(0xFFd1d1d1);
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
        scale: Tween(begin: 0.92, end: 1.03).animate(CurvedAnimation(
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
      padding: EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          border:
          (widget.specialDays != null && widget.specialDays.contains(day))
              ? Border.all(width: 1, color: holderColor)
              : null,
          shape: BoxShape.circle,
          color: widget.isSelected ? holderColor : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (widget.highlightedDays != null &&
                widget.highlightedDays.contains(day))
                ? buildDot()
                : SizedBox(),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: (widget.dayTextStyle != null)
                      ? widget.dayTextStyle
                      : TextStyle(
                    color: widget.isSelected
                        ? widget.selectedDayColor ?? widget.primaryColor
                        : holderColor,
                    fontSize: 15,
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
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: holderColor,
        shape: BoxShape.circle,
      ),
    ),
  );
}
