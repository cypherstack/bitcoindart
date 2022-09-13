import 'dart:typed_data';

import 'package:bech32/bech32.dart';
import 'package:bs58check/bs58check.dart' as bs58check;

import 'models/networks.dart';
import 'payments/index.dart' show PaymentData;
import 'payments/p2pkh.dart';
import 'payments/p2sh.dart';
import 'payments/p2wpkh.dart';

class Address {
  static bool validateAddress(String address,
      [NetworkType? nw, String overridePrefix = '']) {
    try {
      addressToOutputScript(address, nw, overridePrefix);
      return true;
    } catch (err) {
      return false;
    }
  }

  static Uint8List addressToOutputScript(String address,
      [NetworkType? nw, String overridePrefix = '']) {
    var network = nw ?? bitcoin;
    var decodeBase58;
    var decodeBech32;
    try {
      decodeBase58 = bs58check.decode(address);
    } catch (err) {
      // Base58check decode fail
    }
    if (decodeBase58 != null) {
      if (decodeBase58[0] == network.pubKeyHash) {
        return P2PKH(data: PaymentData(address: address), network: network)
            .data
            .output!;
      }
      if (decodeBase58[0] == network.scriptHash) {
        return P2SH(data: PaymentData(address: address), network: network)
            .data
            .output!;
      }
      throw ArgumentError('Invalid version or Network mismatch');
    } else {
      try {
        decodeBech32 = segwit.decode(address, overridePrefix);
      } catch (err) {
        // Bech32 decode fail
      }
      if (decodeBech32 != null) {
        if (network.bech32 != decodeBech32.hrp) {
          throw ArgumentError('Invalid prefix or Network mismatch');
        }
        if (decodeBech32.version != 0) {
          throw ArgumentError('Invalid address version');
        }
        var p2wpkh = P2WPKH(
            data: PaymentData(address: address),
            network: network,
            overridePrefix: overridePrefix);
        return p2wpkh.data.output!;
      }
    }
    throw ArgumentError(address + ' has no matching Script');
  }
}
