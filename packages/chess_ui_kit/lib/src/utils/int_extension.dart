extension IntExtension on int {
  String get formatDuration {
    String formattedDuration = "";
    if (this <= 60) return "0 daqiqa";

    int hours = this ~/ 3600;
    int minutes = (this % 3600) ~/ 60;

    if (hours > 0) {
      formattedDuration += "$hours soat";
    }
    if (minutes > 0) {
      if (hours > 0) formattedDuration += " ";
      formattedDuration += "$minutes daqiqa";
    }

    return formattedDuration.trim();
  }

  String get formatTimer {
    final minutes = (this ~/ 60).toString().padLeft(1, '0');
    final remainingSeconds = (this % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}
