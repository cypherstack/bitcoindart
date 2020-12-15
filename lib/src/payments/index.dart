import 'dart:typed_data';

class PaymentData {
  String name;
  String address;
  Uint8List hash;
  Uint8List output;
  Uint8List signature;
  Uint8List pubkey;
  Uint8List input;
  List<Uint8List> witness;
  PaymentData redeem;

  PaymentData(
      {this.name,
      this.address,
      this.hash,
      this.output,
      this.pubkey,
      this.input,
      this.signature,
      this.witness,
      this.redeem});

  dynamic operator [](String key) {
    switch (key) {
      case 'name':
        return name;
      case 'address':
        return address;
      case 'hash':
        return hash;
      case 'output':
        return output;
      case 'pubkey':
        return pubkey;
      case 'input':
        return input;
      case 'signature':
        return signature;
      case 'witness':
        return witness;
      case 'redeem':
        return redeem;
      default:
        throw ArgumentError('Invalid PaymentData key');
    }
  }

  @override
  String toString() {
    return 'PaymentData{name: $name, address: $address, hash: $hash, output: $output, signature: $signature, pubkey: $pubkey, input: $input, witness: $witness}';
  }
}
