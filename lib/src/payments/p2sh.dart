import 'dart:typed_data';
import 'package:meta/meta.dart';
// import 'package:bip32/src/utils/ecurve.dart' show isPoint;
import 'package:bs58check/bs58check.dart' as bs58check;

import '../crypto.dart';
import '../models/networks.dart';
import '../payments/index.dart' show PaymentData;
import '../utils/script.dart' as bscript;
import '../utils/constants/op.dart';

class P2SH {
  PaymentData data;
  NetworkType network;
  P2SH({@required data, network}) {
    this.network = network ?? bitcoin;
    this.data = data;
    _init();
  }
  _init() {
    if (data.redeem != null) {
      _checkRedeem(data.redeem);
      if (data.redeem.output != null) {
        data.hash = hash160(data.redeem.output);
        _getDataFromHash();

        if (data.redeem.input != null) {
          List<dynamic> _chunks = bscript.decompile(data.redeem.input);
          _chunks.add(data.redeem.output);
          _getDataFromChunk(_chunks);
        }
      }
    } else if (data.input != null) {
      _getDataFromInput();
      if (data.redeem.output != null) {
        data.hash = hash160(data.redeem.output);
        _getDataFromHash();
      }
    }
  }

  void _getDataFromHash() {
    if (data.address == null) {
      final payload = new Uint8List(21);
      payload.buffer.asByteData().setUint8(0, network.scriptHash);
      payload.setRange(1, payload.length, data.hash);
      data.address = bs58check.encode(payload);
    }

    if (data.output == null) {
      data.output = bscript.compile([
        OPS['OP_HASH160'],
        data.hash,
        OPS['OP_EQUAL'],
      ]);
    }
  }

  _checkRedeem(PaymentData redeem) {
    // is the redeem output empty/invalid?
    if (redeem.output != null) {
      final decompile = bscript.decompile(redeem.output);
      if (decompile.length < 1) {
        throw new ArgumentError('Redeem.output too short');
      }
    }

    if (redeem.input != null) {
      // TODO
    }
  }

  _getDataFromChunk([List<dynamic> _chunks]) {
    if (data.input == null && _chunks != null) {
      data.input = bscript.compile(_chunks);
    }
  }

  _getDataFromInput() {
    if (data.redeem == null) {
      data.redeem = _redeem();
    }
  }

  _redeem() {
    final chunks = bscript.decompile(data.input);
    return new PaymentData(
      output: chunks[chunks.length - 1],
      input: bscript.compile(chunks.sublist(0, chunks.length - 1)),
      witness: data.witness ?? [],
    );
  }
}
