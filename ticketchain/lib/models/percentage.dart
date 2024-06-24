class Percentage {
  final BigInt value;
  final BigInt decimals;

  Percentage(
    this.value,
    this.decimals,
  );

  Percentage.fromTuple(List tuple)
      : value = tuple[0],
        decimals = tuple[1];
}
