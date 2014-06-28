part of date_utils;

String formatDuration (Duration d) {    
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  if (d.inMilliseconds < 0) {
    /* Duration duration =
    new Duration(milliseconds: -d.inMilliseconds);
    return "-$duration";
     */
    return "now";
  }
  var days = d.inDays;
  var hours = d.inHours.remainder(Duration.HOURS_PER_DAY);
  String twoDigitMinutes =
      twoDigits(d.inMinutes.remainder(Duration.MINUTES_PER_HOUR));       
  if (days == 0) {
    return "${d.inHours} hours ${twoDigitMinutes} min";
  }
  else {
    return "${days} days ${hours} hours";
  }
}