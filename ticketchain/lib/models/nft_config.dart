class NFTConfig {
  final String name;
  final String symbol;
  final String baseURI;

  NFTConfig(
    this.name,
    this.symbol,
    this.baseURI,
  );

  NFTConfig.fromTuple(
    List tuple,
  )   : name = tuple[0],
        symbol = tuple[1],
        baseURI = tuple[2];
}
