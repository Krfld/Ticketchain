// import 'package:eth_millions/controllers/blockchain_controller.dart';
// import 'package:eth_millions/models/eth_millions_contract.dart';
// import 'package:eth_millions/models/events/claim_event.dart';
// import 'package:eth_millions/models/events/draw_event.dart';
// import 'package:eth_millions/models/events/entry_event.dart';
// import 'package:eth_millions/models/events/fund_event.dart';
// import 'package:eth_millions/models/events/win_event.dart';
// import 'package:eth_millions/models/structs/entry_config.dart';
// import 'package:eth_millions/models/structs/lottery_config.dart';
// import 'package:eth_millions/models/structs/points.dart';
// import 'package:eth_millions/models/structs/schedule_config.dart';
// import 'package:eth_millions/models/structs/ticket.dart';
// import 'package:eth_millions/models/structs/vrf_coordinator_config.dart';
// import 'package:eth_millions/utils/print.dart';
// import 'package:flutter_web3/flutter_web3.dart';
// import 'package:get/get.dart';

// final ethMillions = _EthMillionsService();

// class _EthMillionsService {
//   final Contract _contract = Contract(EthMillionsContract.address, EthMillionsContract.abi, provider!);

//   final Signer _signer = provider!.getSigner();

//   final RxList<DrawEvent> _draws = <DrawEvent>[].obs;
//   final RxList<EntryEvent> _entries = <EntryEvent>[].obs;
//   final RxList<WinEvent> _wins = <WinEvent>[].obs;
//   final RxList<ClaimEvent> _claims = <ClaimEvent>[].obs;
//   final RxList<FundEvent> _funds = <FundEvent>[].obs;

//   List<DrawEvent> get draws => _draws;
//   List<EntryEvent> get entries => _entries;
//   List<WinEvent> get wins => _wins;
//   List<ClaimEvent> get claims => _claims;
//   List<FundEvent> get funds => _funds;

//   _EthMillionsService() {
//     _contract.on('DrawEvent', (lotteryId, draw, jackpot, players, event) {
//       final drawEvent = DrawEvent.fromTuple(Event.fromJS(event).args);
//       l(drawEvent, prefix: 'DrawEvent');
//       _draws.add(drawEvent);
//     });

//     _contract.on('EntryEvent', (lotteryId, player, entry, event) {
//       final entryEvent = EntryEvent.fromTuple(Event.fromJS(event).args);
//       l(entryEvent, prefix: 'EntryEvent');
//       _entries.add(entryEvent);
//     });

//     _contract.on('WonEvent', (lotteryId, player, points, prize, event) {
//       final winEvent = WinEvent.fromTuple(Event.fromJS(event).args);
//       l(winEvent, prefix: 'WonEvent');
//       _wins.add(winEvent);
//     });

//     _contract.on('ClaimedEvent', (player, amount, event) {
//       final claimEvent = ClaimEvent.fromTuple(Event.fromJS(event).args);
//       l(claimEvent, prefix: 'ClaimedEvent');
//       _claims.add(claimEvent);
//     });

//     _contract.on('FundedEvent', (funder, amount, event) {
//       final fundEvent = FundEvent.fromTuple(Event.fromJS(event).args);
//       l(fundEvent, prefix: 'FundedEvent');
//       _funds.add(fundEvent);
//     });

//     _init();
//   }

//   Future<void> _init() async {
//     try {
//       _draws.value = (await _contract.queryFilter(_contract.getFilter('DrawEvent'), EthMillionsContract.creationBlock))
//           .map((e) => DrawEvent.fromTuple(e.args))
//           .toList();

//       _entries.value = (await _contract.queryFilter(_contract.getFilter('EntryEvent'), EthMillionsContract.creationBlock))
//           .map((e) => EntryEvent.fromTuple(e.args))
//           .toList();

//       _wins.value = (await _contract.queryFilter(_contract.getFilter('WonEvent'), EthMillionsContract.creationBlock))
//           .map((e) => WinEvent.fromTuple(e.args))
//           .toList();

//       _claims.value = (await _contract.queryFilter(_contract.getFilter('ClaimedEvent'), EthMillionsContract.creationBlock))
//           .map((e) => ClaimEvent.fromTuple(e.args))
//           .toList();

//       _funds.value = (await _contract.queryFilter(_contract.getFilter('FundedEvent'), EthMillionsContract.creationBlock))
//           .map((e) => FundEvent.fromTuple(e.args))
//           .toList();
//     } catch (e) {
//       l(e, prefix: 'EthMillionsService init', isError: true);
//     }
//   }

//   Future<dynamic> _read(String method, [List<dynamic> args = const []]) async {
//     try {
//       final output = await _contract.call(method, args);
//       return (output is List) ? output : output.toString();
//     } catch (e) {
//       l(e, prefix: method, isError: true);
//     }
//   }

//   Future<dynamic> _write(String method, [List<dynamic> args = const [], TransactionOverride? override]) async {
//     try {
//       await bc.connect();
//       final tx = await _contract.connect(_signer).send(method, args, override);
//       l(tx);
//       final receipt = await tx.wait();
//       l(receipt);
//     } catch (e) {
//       l(e, prefix: method, isError: true);
//     }
//   }

//   test() async {
//     l(draws, prefix: 'draws');
//     l(entries, prefix: 'entries');
//     l(wins, prefix: 'wins');
//     l(claims, prefix: 'claims');
//     l(funds, prefix: 'funds');
//   }

//   /// read

//   Future<EntryConfig> getEntryConfig() async => EntryConfig.fromTuple(await _read('getEntryConfig'));

//   Future<int> getJackpotPrize() async => int.parse((await _read('getJackpotPrize')));

//   Future<int> getLotteryBalance() async => int.parse((await _read('getLotteryBalance')));

//   Future<int> getLotteryBalanceDistribution(int distribution) async => int.parse((await _read('getLotteryBalanceDistribution', [distribution])));

//   Future<LotteryConfig> getLotteryConfig() async => LotteryConfig.fromTuple(await _read('getLotteryConfig'));

//   Future<int> getLotteryId() async => int.parse((await _read('getLotteryId')));

//   Future<bool> getLotteryState() async => (await _read('getLotteryState')) == 'true';

//   Future<Points> getPoints(Ticket entry, Ticket draw) async => Points.fromTuple(await _read('getPoints', [entry.toTuple(), draw.toTuple()]));

//   Future<int> getPointsTier(Points points) async => int.parse((await _read('getPointsTier', [points.toTuple()])));

//   Future<int> getPrizeFundDistribution(Points points) async => int.parse((await _read('getPrizeFundDistribution', [points.toTuple()])));

//   Future<List<int>> getPrizesTier() async => ((await _read('getPrizesTier')) as List).map((e) => int.parse(e.toString())).toList();

//   Future<ScheduleConfig> getScheduleConfig() async => ScheduleConfig.fromTuple(await _read('getScheduleConfig'));

//   Future<int> getScheduleStart() async => int.parse((await _read('getScheduleStart')));

//   Future<Points> getTierPoints(int tier) async => Points.fromTuple(await _read('getTierPoints', [tier]));

//   Future<VRFCoordinatorConfig> getVRFCoordinatorConfig() async => VRFCoordinatorConfig.fromTuple(await _read('getVRFCoordinatorConfig'));

//   /// write

//   Future claimPrizes() async => await _write('claimPrizes');

//   Future collectFees(String to) async => await _write('collectFees', [to]);

//   Future enterLottery(List<Ticket> entries) async => await _write(
//         'enterLottery',
//         [entries.map((e) => e.toTuple()).toList()],
//         TransactionOverride(value: BigInt.from((await getEntryConfig()).price * entries.length)),
//       );
// }
