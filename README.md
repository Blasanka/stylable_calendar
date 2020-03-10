## stylable_calendar

A calendar that is less complicated and can customize as you want.

Parameters available:
```
StylableCalendar({
    this.selectedDate, // Provide a DateTime object
    this.specialDays, // will mark with border. ex: [1, 4, 6]
    this.isLoading, // if needed to animate after some task
    this.highlightedDays, // will mark with dot. ex: [1, 4, 6]
    this.onNext, // (DateTime date) {}
    this.onPrevious, // (DateTime date) {}
    this.primaryColor = Colors.black54,
    this.primaryColorDark = Colors.black,
    this.secondaryColor = Colors.white,
    this.isCollapsed = false,
    this.isPreviousActive = false,
    this.isNextActive = false,
});
```