import 'package:bitcoindart/src/payments/index.dart' show PaymentData;
import 'package:bitcoindart/src/payments/p2pkh.dart';
import 'package:bitcoindart/src/payments/p2sh.dart';
import 'package:bitcoindart/src/payments/p2wpkh.dart';
import 'package:bitcoindart/src/models/networks.dart' as networks;
import 'package:test/test.dart';
import 'package:bitcoindart/src/utils/script.dart' as bscript;
import 'dart:io';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'dart:typed_data';

dynamic getPayment({String type, dynamic data, dynamic network}) {
  switch (type) {
    case 'p2pkh':
      return P2PKH(data: data, network: network);
    case 'p2sh':
      return P2SH(data: data, network: network);
    case 'p2wpkh':
      return P2WPKH(data: data, network: network);
  }
}

void main() {
  ['p2pkh', 'p2sh', 'p2wpkh'].forEach((p) {
    final fixtures = json.decode(
        File('./test/fixtures/${p}.json').readAsStringSync(encoding: utf8));

    group('(valid case)', () {
      (fixtures['valid'] as List<dynamic>).forEach((f) {
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
      (fixtures['invalid'] as List<dynamic>).forEach((f) {
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
          (f['disabled'] as List<dynamic>).forEach((k) {
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
  var input;
  if (x['inputHex'] is String) {
    input = HEX.decode(x['inputHex']) as Uint8List;
  }
  if (x['input'] != null) {
    input = bscript.fromASM(x['input']);
  }

  final witness = x['witness'] != null
      ? (x['witness'] as List<dynamic>)
          .map((e) => HEX.decode(e.toString()) as Uint8List)
          .toList()
      : null;
  final output = x['output'] != null
      ? bscript.fromASM(x['output'])
      : x['outputHex'] != null ? HEX.decode(x['outputHex']) : null;
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
  return PaymentData(
      address: address,
      hash: hash,
      input: input,
      output: output,
      pubkey: pubkey,
      signature: signature,
      witness: witness,
      redeem: redeem);
}

networks.NetworkType _preformNetwork(dynamic x) {
  if (x['network'] == 'testnet') {
    return networks.testnet;
  }
  if (x['redeem'] != null && x['redeem']['network'] == 'testnet') {
    return networks.testnet;
  }
  return networks.bitcoin;
}

PaymentData _from(String path, PaymentData paymentData, [PaymentData result]) {
  final paths = path.split('.');

  result = result ?? PaymentData();

  var r = result;

  paths.asMap().forEach((i, k) {
    if (i < paths.length - 1) {
      r[k] = r[k] ?? PaymentData();

      // recurse
      r = r[k];
      paymentData = paymentData[k];
    } else {
      r[k] = paymentData[k];
    }
  });

  return result;
}

void _equateBase(PaymentData paymentData, dynamic expected) {
  if (expected['output'] != null) {
    expect(tryASM(paymentData.output), tryASM(expected['output']));
  }
  if (expected['input'] != null) {
    expect(tryASM(paymentData.input), tryASM(expected['input']));
  }
  if (expected['witness'] != null) {
    expect(tryHex(paymentData.witness), tryHex(expected['witness']));
  }
}

void _equate(PaymentData paymentData, dynamic expected,
    [PaymentData arguments]) {
  _equateBase(paymentData, expected);

  if (expected['redeem'] != null) {
    _equateBase(paymentData.redeem, expected['redeem']);
  }

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
  if (expected['signature'] != null) {
    expect(tryHex(paymentData.signature), tryHex(expected['signature']));
  }
}

dynamic tryHex(dynamic x) {
  if (x is Uint8List) {
    return HEX.encode(x);
  }
  if (x is List<dynamic>) {
    return x.map(tryHex);
  }
  return x;
}

dynamic tryASM(dynamic x) {
  if (x is List<dynamic>) {
    return bscript.toASM(x);
  }
  return x;
}
