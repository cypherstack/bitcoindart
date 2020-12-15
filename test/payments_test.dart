import 'package:bitcoindart/src/payments/index.dart' show PaymentData;
import 'package:bitcoindart/src/payments/p2pkh.dart';
import 'package:bitcoindart/src/payments/p2sh.dart';
import 'package:bitcoindart/src/payments/p2wpkh.dart';
import 'package:bitcoindart/src/models/networks.dart' as NETWORKS;
import 'package:test/test.dart';
import 'package:bitcoindart/src/utils/script.dart' as bscript;
import 'dart:io';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'dart:typed_data';

dynamic getPayment({String type, dynamic data, dynamic network}) {
  switch (type) {
    case 'p2pkh':
      return new P2PKH(data: data, network: network);
    case 'p2sh':
      return new P2SH(data: data, network: network);
    case 'p2wpkh':
      return new P2WPKH(data: data, network: network);
  }
}

main() {
  ['p2pkh', 'p2sh', 'p2wpkh'].forEach((p) {
    final fixtures = json.decode(
        new File("./test/fixtures/${p}.json").readAsStringSync(encoding: utf8));

    group('(valid case)', () {
      (fixtures["valid"] as List<dynamic>).forEach((f) {
        test(f['description'] + ' as expected', () {
          final arguments = _preformPaymentData(f['arguments']);
          final network = _preformNetwork(f['arguments']);

          final payment =
              getPayment(type: p, data: arguments, network: network);

          _equate(payment.data, f['expected'], arguments);
        });
      });
    });

    group('(invalid case)', () {
      (fixtures["invalid"] as List<dynamic>).forEach((f) {
        test(
            'throws ' +
                f['exception'] +
                (f['description'] != null ? ('for ' + f['description']) : ''),
            () {
          final arguments = _preformPaymentData(f['arguments']);
          try {
            final payment = getPayment(type: p, data: arguments);
            expect(payment, isArgumentError);
          } catch (err) {
            expect((err as ArgumentError).message, f['exception']);
          }
        });
      });
    });

    if (fixtures['dynamic'] == null) return;

    group('(dynamic case)', () {
      final depends = fixtures['dynamic']['depends'] as Map<String, dynamic>;
      final details = fixtures['dynamic']['details'] as List<dynamic>;

      details.forEach((f) {
        final detail = _preformPaymentData(f);
        final disabled = {};
        if (f['disabled'] != null) {
          (f["disabled"] as List<dynamic>).forEach((k) {
            disabled[k] = true;
          });
        }

        depends.forEach((key, depend) {
          if (disabled[key] == true) return;

          final dependencies = depend as List;

          dependencies.forEach((dependency) {
            if (!(dependency is List)) {
              dependency = [dependency];
            }

            PaymentData args;
            dependency.forEach((d) {
              args = _from(d, detail, args);
            });

            final expected = _from(key, detail);

            test(
                f['description'] +
                    ', ' +
                    key +
                    ' derives from ' +
                    json.encode(dependency), () {
              final payment = getPayment(type: p, data: args);
              _equate(payment.data, expected);
            });
          });
        });
      });
    });
  });
}

PaymentData _preformPaymentData(dynamic x) {
  final address = x['address'];
  final hash = x['hash'] != null ? HEX.decode(x['hash']) : null;
  final input = x['input'] != null ? bscript.fromASM(x['input']) : null;
  final witness = x['witness'] != null
      ? (x['witness'] as List<dynamic>)
          .map((e) => HEX.decode(e.toString()) as Uint8List)
          .toList()
      : null;
  final output = x['output'] != null
      ? bscript.fromASM(x['output'])
      : x['outputHex'] != null
          ? HEX.decode(x['outputHex'])
          : null;
  final pubkey = x['pubkey'] != null ? HEX.decode(x['pubkey']) : null;
  final signature = x['signature'] != null ? HEX.decode(x['signature']) : null;

  PaymentData redeem;

  if (x['redeem'] != null) {
    redeem = PaymentData();

    if (x['redeem']['input'] is String) {
      redeem.input = bscript.fromASM(x['redeem']['input']);
    }
    if (x['redeem']['output'] is String) {
      redeem.output = bscript.fromASM(x['redeem']['output']);
    }
    if (x['redeem']['witness'] is List) {
      redeem.witness = (x['redeem']['witness'] as List<dynamic>)
          .map((e) => HEX.decode(e.toString()) as Uint8List)
          .toList();
    }
  }
  return new PaymentData(
      address: address,
      hash: hash,
      input: input,
      output: output,
      pubkey: pubkey,
      signature: signature,
      witness: witness,
      redeem: redeem);
}

_preformNetwork(dynamic x) {
  if (x['network'] == 'testnet') {
    return NETWORKS.testnet;
  }
  if (x['redeem'] != null && x['redeem']['network'] == 'testnet') {
    return NETWORKS.testnet;
  }
  return NETWORKS.bitcoin;
}

PaymentData _from(String path, PaymentData paymentData, [PaymentData result]) {
  final paths = path.split('.');

  var r = result ?? PaymentData();

  paths.asMap().forEach((i, k) {
    if (i < paths.length - 1) {
    } else {
      _copyPaymentDataByKey(k, paymentData, r);
    }
  });

  return r;
}

_copyPaymentDataByKey(String key, PaymentData from, PaymentData to) {
  switch (key) {
    case 'name':
      to.name = from.name;
      break;
    case 'address':
      to.address = from.address;
      break;
    case 'hash':
      to.hash = from.hash;
      break;
    case 'output':
      to.output = from.output;
      break;
    case 'signature':
      to.signature = from.signature;
      break;
    case 'pubkey':
      to.pubkey = from.pubkey;
      break;
    case 'input':
      to.input = from.input;
      break;
    case 'witness':
      to.witness = from.witness;
      break;
    case 'redeem':
      to.redeem = from.redeem;
      break;
    default:
      throw new ArgumentError('Invalid PaymentData key');
  }
}

_equate(PaymentData paymentData, dynamic expected, [PaymentData arguments]) {
  if (expected['name'] != null) {
    expect(paymentData.name, expected['name']);
  }
  if (expected['address'] != null) {
    expect(paymentData.address, expected['address']);
  }
  if (expected['hash'] != null) {
    expect(tryHex(paymentData.hash), tryHex(expected['hash']));
  }
  if (expected['pubkey'] != null) {
    expect(tryHex(paymentData.pubkey), tryHex(expected['pubkey']));
  }
  if (expected['input'] != null) {
    expect(tryASM(paymentData.input), tryASM(expected['input']));
  }
  if (expected['output'] != null) {
    expect(tryASM(paymentData.output), tryASM(expected['output']));
  }
  if (expected['signature'] != null) {
    expect(tryHex(paymentData.signature), tryHex(expected['signature']));
  }
  if (expected['witness'] != null) {
    expect(tryHex(paymentData.witness), tryHex(expected['witness']));
  }
}

tryHex(dynamic x) {
  if (x is Uint8List) {
    return HEX.encode(x);
  }
  if (x is List<dynamic>) {
    return x.map(tryHex);
  }
  return x;
}

tryASM(dynamic x) {
  if (x is List<dynamic>) {
    return bscript.toASM(x);
  }
  return x;
}
