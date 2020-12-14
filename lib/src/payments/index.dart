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

  @override
  String toString() {
    return 'PaymentData{name: $name, address: $address, hash: $hash, output: $output, signature: $signature, pubkey: $pubkey, input: $input, witness: $witness}';
  }
}
