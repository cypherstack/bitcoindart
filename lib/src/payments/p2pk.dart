import 'package:meta/meta.dart';
import 'package:bip32/src/utils/ecurve.dart' show isPoint;
import '../models/networks.dart';
import '../payments/index.dart' show PaymentData;
import '../utils/constants/op.dart';

class P2PK {
  PaymentData data;
  NetworkType network;
  P2PK({@required data, network}) {
    this.network = network ?? bitcoin;
    this.data = data;
    _init();
  }

  void _init() {
    if (data.output != null) {
      if (data.output[data.output.length - 1] != OPS['OP_CHECKSIG']) {
        throw ArgumentError('Output is invalid');
      }
      if (!isPoint(data.output.sublist(1, -1))) {
        throw ArgumentError('Output pubkey is invalid');
      }
    }
    if (data.input != null) {
      // TODO
    }
  }
}
