class Percentage {
  final int value;
  final int decimals;

  Percentage(
    this.value,
    this.decimals,
  );

  Percentage.fromTuple(List tuple)
      : value = tuple[0].toInt(),
        decimals = tuple[1].toInt();
}
