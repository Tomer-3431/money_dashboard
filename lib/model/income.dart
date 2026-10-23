class Income {
  final String id;
  final String name;
  final String description;
  late final DateTime dateTime;
  final int amount;
  final int type;
  final String location;
  late final DateTime reportDate;

  Income({
    required this.id,
    this.name = "",
    this.description = "",
    DateTime? dateTime,
    this.amount = 0,
    this.type = -1,
    this.location = "",
    DateTime? reportDate,
  }) {
    this.dateTime = dateTime ?? DateTime.now();
    this.reportDate = reportDate ?? DateTime.now();
  }
}
