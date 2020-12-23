// Created by KY

import 'dart:convert';
// 导入 Uint8List
import 'dart:typed_data';
// 导入 SHA256Digest
import 'package:pointycastle/digests/sha256.dart';
// 导入 RIPEMD160Digest
import 'package:pointycastle/digests/ripemd160.dart';

import 'package:bitcoindart/src/models/networks.dart' as networks;
import 'package:bitcoindart/src/payments/p2pkh.dart' show P2PKH;
import 'package:bitcoindart/src/payments/index.dart' show PaymentData;
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:bitcoindart/src/ecpair.dart' show ECPair;
import 'package:bitcoindart/src/transaction_builder.dart';

List<int> rng(int number) {
  return utf8.encode('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz');
}

List<int> rngKeybag(int number) {
  return utf8.encode('zzzzzzzzzzzzzzzzzzzzzzzzzzkeybag');
}

Uint8List hash160(Uint8List buffer) {
  final _tmp = SHA256Digest().process(buffer);
  return RIPEMD160Digest().process(_tmp);
}

// 通过原始方式创建地址
void createAddressInOriginalWay() {
  final keyPair = ECPair.makeRandom(rng: rng);
  print(keyPair.publicKey);
  print(keyPair.publicKey.length);
  // pubkey：Uint8List 格式的公钥
  var hash = hash160(keyPair.publicKey);
  print(hash);
  print(hash.length);
  final payload = Uint8List(21);
  payload.buffer.asByteData().setUint8(0, 0x00);
  payload.setRange(1, payload.length, hash);
  print(payload);
  var address = bs58check.encode(payload);
  print(address);
}

dynamic createAddress(Function rng) {
  final keyPair = ECPair.makeRandom(rng: rng);
  final wif = keyPair.toWIF();
  final address =
      P2PKH(data: PaymentData(pubkey: keyPair.publicKey)).data.address;
  print(wif);
  print(address);

  return {
    'wif': wif,
    'address': address,
  };
}

// 创建交易
void createTransaction() {
  final alice =
      ECPair.fromWIF('L2uPYXe17xSTqbCjZvL2DsyXPCbXspvcu5mHLDYUgzdUbZGSKrSr');
  final address2 =
      P2PKH(data: PaymentData(pubkey: alice.publicKey)).data.address;
  print(address2);
  final txb = TransactionBuilder();

  txb.setVersion(2);
  txb.addInput(
      '7d067b4a697a09d2c3cff7d4d9506c9955e93bff41bf82d439da7d030382bc3e',
      0); // Alice's previous transaction output, has 15000 satoshis
  txb.addOutput('1KRMKfeZcmosxALVYESdPNez1AP1mEtywp', 80000);
  txb.addOutput('1KRMKfeZcmosxALVYESdPNez1AP1mEtywp', 80000);
  // (in)90000 - (out)80000 = (fee)10000, this is the miner fee

  txb.sign(vin: 0, keyPair: alice);

  print(txb.build().toHex());

  // 02000000013ebc8203037dda39d482bf41ff3be955996c50d9d4f7cfc3d2097a694a7b067d000000006b483045022100931b6db94aed25d5486884d83fc37160f37f3368c0d7f48c757112abefec983802205fda64cff98c849577026eb2ce916a50ea70626a7669f8596dd89b720a26b4d501210365db9da3f8a260078a7e8f8b708a1161468fb2323ffda5ec16b261ec1056f455ffffffff0180380100000000001976a914ca0d36044e0dc08a22724efa6f6a07b0ec4c79aa88ac00000000
}

// 创建Testnet地址
Map<String, dynamic> createTestnetAddress(Function rng) {
  final testnet = networks.testnet;
  final keyPair = ECPair.makeRandom(network: testnet, rng: rng);
  final wif = keyPair.toWIF();
  final address =
      P2PKH(data: PaymentData(pubkey: keyPair.publicKey), network: testnet)
          .data
          .address;
  print(wif);
  print(address);

  return {
    'wif': wif,
    'address': address,
  };
}

void createTestnetTransaction(String txHash) {
  final keybag =
      ECPair.fromWIF('cRgnQe9MUu1JznntrLaoQpB476M8PURvXVQB5MHjaqzhL42Cse1T');
  final address = P2PKH(
          data: PaymentData(pubkey: keybag.publicKey),
          network: networks.testnet)
      .data
      .address;
  print(address);
  final txb = TransactionBuilder(network: networks.testnet);

  txb.setVersion(1);
  txb.addInput(
      txHash, 0); // Keybag's previous transaction output, has 15000 satoshis
  txb.addOutput('moTUMqKxSXrGeF8ktYcawLLVr6Mg46TQdQ', 20000000);
  txb.addOutput('msXCejAWLAPZym8JK2516x7gbu3giKWUP3', 10000000 - 150);
  // (in)90000 - (out)80000 = (fee)10000, this is the miner fee

  txb.sign(vin: 0, keyPair: keybag);

  print(txb.build().toHex());
}

void main() {
  // createAddressInOriginalWay();

  // createAddress(rng);

  // createTestnetAddress(rng);
  // wif: cRgnQe9MUu1JznntrLaoQpB476M8PURvXVQB5R2eqms5tXnzNsrr
  // address: mubSzQNtZfDj1YdNP6pNDuZy6zs6GDn61L

  // createTestnetAddress(rngKeybag);
  // wif: cRgnQe9MUu1JznntrLaoQpB476M8PURvXVQB5MHjaqzhL42Cse1T
  // address: msXCejAWLAPZym8JK2516x7gbu3giKWUP3

  createTestnetTransaction(
      'f752b9c61ed56d61049bf24317c683762cdf66ef91f9562d234cca18b9503aee');

  // createTransaction();
}
