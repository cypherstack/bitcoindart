import 'dart:typed_data';
import 'package:meta/meta.dart';
// import 'package:bip32/src/utils/ecurve.dart' show isPoint;
import 'package:bs58check/bs58check.dart' as bs58check;

import '../crypto.dart';
import '../models/networks.dart';
import '../payments/index.dart' show PaymentData;
// import '../utils/script.dart' as bscript;
// import '../utils/constants/op.dart';

class P2SH {
  PaymentData data;
  PaymentData redeem;
  NetworkType network;
  P2SH({@required redeem, network}) {
    this.network = network ?? bitcoin;
    this.redeem = redeem;
    this.data = PaymentData();
    _init();
  }
  _init() {
    print(redeem);

    if (redeem.output != null) {
      _checkRedeem(redeem);

      data.hash = hash160(redeem.output);
      _getDataFromRedeem();
    }
  }

  void _getDataFromRedeem() {
    if (data.address == null) {
      final payload = new Uint8List(21);
      payload.buffer.asByteData().setUint8(0, network.scriptHash);
      payload.setRange(1, payload.length, data.hash);
      data.address = bs58check.encode(payload);
    }
  }

  _checkRedeem(PaymentData redeem) {
    // TODO
  }
}
