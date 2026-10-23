/// A financial goal: a name and the amount of money to reach.
class Goal {
  final String id;
  final String name;
  final int amount;

  const Goal({
    required this.id,
    this.name = "",
    this.amount = 0,
  });
}
