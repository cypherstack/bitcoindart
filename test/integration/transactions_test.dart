import 'package:bitcoindart/src/ecpair.dart';
import 'package:bitcoindart/src/models/networks.dart' as networks;
import 'package:bitcoindart/src/payments/index.dart' show PaymentData;
import 'package:bitcoindart/src/payments/p2pkh.dart' show P2PKH;
import 'package:bitcoindart/src/payments/p2sh.dart' show P2SH;
import 'package:bitcoindart/src/payments/p2wpkh.dart' show P2WPKH;
import 'package:bitcoindart/src/transaction_builder.dart';
import 'package:test/test.dart';

void main() {
  group('bitcoinjs-lib (transactions)', () {
    test('can create a 1-to-1 Transaction', () {
      final alice = ECPair.fromWIF(
          'L1uyy5qTuGrVXrmrsvHWHgVzW9kKdrp27wBC7Vs6nZDTF2BRUVwy');
      final txb = TransactionBuilder();

      txb.setVersion(1);
      txb.addInput(
          '61d520ccb74288c96bc1a2b20ea1c0d5a704776dd0164a396efec3ea7040349d',
          0); // Alice's previous transaction output, has 15000 satoshis
      txb.addOutput('1cMh228HTCiwS8ZsaakH8A8wze1JR5ZsP', 12000);
      // (in)15000 - (out)12000 = (fee)3000, this is the miner fee

      txb.sign(vin: 0, keyPair: alice);

      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '01000000019d344070eac3fe6e394a16d06d7704a7d5c0a10eb2a2c16bc98842b7cc20d561000000006b48304502210088828c0bdfcdca68d8ae0caeb6ec62cd3fd5f9b2191848edae33feb533df35d302202e0beadd35e17e7f83a733f5277028a9b453d525553e3f5d2d7a7aa8010a81d60121029f50f51d63b345039a290c94bffd3180c99ed659ff6ea6b1242bca47eb93b59fffffffff01e02e0000000000001976a91406afd46bcdfd22ef94ac122aa11f241244a37ecc88ac00000000');
    });

    test('can create a 2-to-2 Transaction', () {
      final alice = ECPair.fromWIF(
          'L1Knwj9W3qK3qMKdTvmg3VfzUs3ij2LETTFhxza9LfD5dngnoLG1');
      final bob = ECPair.fromWIF(
          'KwcN2pT3wnRAurhy7qMczzbkpY5nXMW2ubh696UBc1bcwctTx26z');

      final txb = TransactionBuilder();
      txb.setVersion(1);
      txb.addInput(
          'b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c',
          6); // Alice's previous transaction output, has 200000 satoshis
      txb.addInput(
          '7d865e959b2466918c9863afca942d0fb89d7c9ac0c99bafc3749504ded97730',
          0); // Bob's previous transaction output, has 300000 satoshis
      txb.addOutput('1CUNEBjYrCn2y1SdiUMohaKUi4wpP326Lb', 180000);
      txb.addOutput('1JtK9CQw1syfWj1WtFMWomrYdV3W2tWBF9', 170000);
      // (in)(200000 + 300000) - (out)(180000 + 170000) = (fee)150000, this is the miner fee

      txb.sign(
          vin: 1,
          keyPair:
              bob); // Bob signs his input, which was the second input (1th)
      txb.sign(
          vin: 0,
          keyPair:
              alice); // Alice signs her input, which was the first input (0th)

      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '01000000024c94e48a870b85f41228d33cf25213dfcc8dd796e7211ed6b1f9a014809dbbb5060000006a473044022041450c258ce7cac7da97316bf2ea1ce66d88967c4df94f3e91f4c2a30f5d08cb02203674d516e6bb2b0afd084c3551614bd9cec3c2945231245e891b145f2d6951f0012103e05ce435e462ec503143305feb6c00e06a3ad52fbf939e85c65f3a765bb7baacffffffff3077d9de049574c3af9bc9c09a7c9db80f2d94caaf63988c9166249b955e867d000000006b483045022100aeb5f1332c79c446d3f906e4499b2e678500580a3f90329edf1ba502eec9402e022072c8b863f8c8d6c26f4c691ac9a6610aa4200edc697306648ee844cfbc089d7a012103df7940ee7cddd2f97763f67e1fb13488da3fbdd7f9c68ec5ef0864074745a289ffffffff0220bf0200000000001976a9147dd65592d0ab2fe0d0257d571abf032cd9db93dc88ac10980200000000001976a914c42e7ef92fdb603af844d064faad95db9bcdfd3d88ac00000000');
    });

    test('can create a Transaction, w/ a P2SH(P2WPKH) input', () {
      final alice = ECPair.fromWIF(
          'L2FroWqrUgsPpTMhpXcAFnVDLPTToDbveh3bhDaU4jhe7Cw6YujN');
      final p2wpkh = P2WPKH(data: PaymentData(pubkey: alice.publicKey)).data;
      final redeemScript = p2wpkh.output;

      final txb = TransactionBuilder();
      txb.setVersion(1);
      txb.addInput(
          'ce5986f6d73d7855351fea94c7cf9eb1a4513bf5e004178835d8e2adb9a0f95d',
          0);
      txb.addOutput('1D8nG3VetkT4CfyXGKm7EdLU1YbMD3Amuj', 60000);

      txb.sign(
          vin: 0,
          keyPair: alice,
          redeemScript: redeemScript,
          witnessValue: 80000);
      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '010000000001015df9a0b9ade2d835881704e0f53b51a4b19ecfc794ea1f3555783dd7f68659ce0000000017160014851a33a5ef0d4279bd5854949174e2c65b1d4500ffffffff0160ea0000000000001976a914851a33a5ef0d4279bd5854949174e2c65b1d450088ac02483045022100cb3929c128fec5108071b662e5af58e39ac8708882753a421455ca80462956f6022030c0f4738dd1a13fc7a34393002d25c6e8a6399f29c7db4b98f53a9475d94ca20121038de63cf582d058a399a176825c045672d5ff8ea25b64d28d4375dcdb14c02b2b00000000');
    });

    test('can create a Transaction, w/ a P2WPKH input', () {
      final alice = ECPair.fromWIF(
          'cUNfunNKXNNJDvUvsjxz5tznMR6ob1g5K6oa4WGbegoQD3eqf4am',
          network: networks.testnet);
      final p2wpkh = P2WPKH(
              data: PaymentData(pubkey: alice.publicKey),
              network: networks.testnet)
          .data;
      final txb = TransactionBuilder(network: networks.testnet);
      txb.setVersion(1);
      txb.addInput(
          '53676626f5042d42e15313492ab7e708b87559dc0a8c74b7140057af51a2ed5b',
          0,
          null,
          p2wpkh
              .output); // Alice's previous transaction output, has 200000 satoshis
      txb.addOutput('tb1qchsmnkk5c8wsjg8vxecmsntynpmkxme0yvh2yt', 1000000);
      txb.addOutput('tb1qn40fftdp6z2lvzmsz4s0gyks3gq86y2e8svgap', 8995000);

      txb.sign(vin: 0, keyPair: alice, witnessValue: 10000000);
      // // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '010000000001015beda251af570014b7748c0adc5975b808e7b72a491353e1422d04f5266667530000000000ffffffff0240420f0000000000160014c5e1b9dad4c1dd0920ec3671b84d649877636f2fb8408900000000001600149d5e94ada1d095f60b701560f412d08a007d11590247304402203c4670ff81d352924af311552e0379861268bebb2222eeb0e66b3cdd1d4345b60220585b57982d958208cdd52f4ead4ecb86cfa9ff7740c2f6933e77135f1cc4c58f012102f9f43a191c6031a5ffae27c5f9911218e78857923284ac1154abc2cc008544b200000000');
    });

    test(
        'can create a 3-to-1 (P2WPKH & P2SH(P2WPKH) & P2PKH to P2WPKH) Transaction',
        () {
      final alice = ECPair.fromWIF(
          'cR6G73NAJjB9SGgf2t4mTDvfer1hmUyRYKS4M5yVnsch5Ee2UmBx',
          network: networks.testnet);
      final p2wpkhAlice = P2WPKH(
              data: PaymentData(pubkey: alice.publicKey),
              network: networks.testnet)
          .data;

      final bob = ECPair.fromWIF(
          'cVZoW8AdvHpzpN1LQH8x5XoBmefB1b9XmzNKT9STPLmHQLokZF9F',
          network: networks.testnet);
      final p2wpkhBob = P2WPKH(
              data: PaymentData(pubkey: bob.publicKey),
              network: networks.testnet)
          .data;
      final redeemScript = p2wpkhBob.output;
      final p2shBob =
          P2SH(data: PaymentData(redeem: p2wpkhBob), network: networks.testnet)
              .data;

      final charlie = ECPair.fromWIF(
          'cR5kcfNWGV68t4SbGQjwRc9e6rPv58U7KH4sVn6gdmocqcnCZV6K',
          network: networks.testnet);
      final p2pkhCharlie = P2PKH(
        data: PaymentData(pubkey: charlie.publicKey),
        network: networks.testnet,
      ).data;

      final txb = TransactionBuilder(network: networks.testnet);
      txb.setVersion(1);
      txb.addInput(
        '5f4e739c996d41d55b4065b957857a687d06065734575db4b6ebf20360560eae',
        0,
        null,
        p2wpkhAlice.output,
      ); // Alice's previous transaction output, has 10000 satoshis
      txb.addInput(
        'a7b9cfcfc94bba0718286396f417c1aed0699d67bec42e8e8a96b69654fbaf71',
        0,
        null,
        p2shBob.output,
      ); // Bob's previous transaction output, has 6000 satoshis
      txb.addInput(
        '776ebbcc487781550edaed0e7f3339087dfcb87ad7e4c0ccd6a55f8bca5d8fcc',
        0,
        null,
        p2pkhCharlie.output,
      ); // Charlie's previous transaction output, has 8000 satoshis

      txb.addOutput('tb1q4hxl786wlk7q3kyshvqqggp4z4j8mlft7e6h5r', 23000);
      // (in)(6000 + 8000 + 10000) - (out)(23000) = (fee)1000, this is the miner fee

      txb.sign(
          vin: 1,
          keyPair: bob,
          redeemScript: redeemScript,
          witnessValue:
              6000); // Bob signs his input, which was the second input (1th)
      txb.sign(
          vin: 0,
          keyPair: alice,
          witnessValue:
              10000); // Alice signs her input, which was the first input (0th)
      txb.sign(
          vin: 2,
          keyPair: charlie,
          witnessValue:
              8000); // Charlie signs his input, which was the last input (2nd)

      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '01000000000103ae0e566003f2ebb6b45d57345706067d687a8557b965405bd5416d999c734e5f0000000000ffffffff71affb5496b6968a8e2ec4be679d69d0aec117f49663281807ba4bc9cfcfb9a70000000017160014cd5479b8f2ee71037c99b7d864eccbde605adca5ffffffffcc8f5dca8b5fa5d6ccc0e4d77ab8fc7d0839337f0eedda0e55817748ccbb6e77000000006b483045022100c9a7a69edf8b636f9c4dd2a5c0046ae7967cc43fbffeb3b52e34286113dc6a9002207beac48b8c3bb5c60a3fa56e552779eafddd4c3a9efd5b41bf3f2d8db098f65601210335e51cac96a2ddb00286aee186b1e895021478ef5ae5ca8da0a9699bd4ebb07fffffffff01d859000000000000160014adcdff1f4efdbc08d890bb0004203515647dfd2b024830450221008ae00f832d2dc0d015b9675c9d4fe4e04bc4314e1f28c0ff3ff9000bec3597e30220449b7933fc7602074602075ef17f41c0db0a5823f0cac7f5d352f98a6458b2d3012102bdc758cb2fa3153b52d2ec61102cc06ec9a541359c205f83a646a7cf15b3e5f902483045022100d4d74ccddec0c764e9ba069acf394a5c7b2cd751e3af28e8262c9677b37897fb022043ba0f7ede765718ed28e3bd5c94b711ee9b78cafcf2247d5e97b699413289c3012102711353556322a96722f0692ec7b25949417e794169f9c239ee5daa1c942390990000000000');
    });

    test('can create a 2-to-1 (P2WPKH & P2SH(P2WPKH) to P2SH) Transaction', () {
      final alice = ECPair.fromWIF(
          'cR6G73NAJjB9SGgf2t4mTDvfer1hmUyRYKS4M5yVnsch5Ee2UmBx',
          network: networks.testnet);
      final p2wpkhAlice = P2WPKH(
              data: PaymentData(pubkey: alice.publicKey),
              network: networks.testnet)
          .data;

      final bob = ECPair.fromWIF(
          'cVZoW8AdvHpzpN1LQH8x5XoBmefB1b9XmzNKT9STPLmHQLokZF9F',
          network: networks.testnet);
      final p2wpkhBob = P2WPKH(
              data: PaymentData(pubkey: bob.publicKey),
              network: networks.testnet)
          .data;
      final redeemScript = p2wpkhBob.output;
      final p2shBob =
          P2SH(data: PaymentData(redeem: p2wpkhBob), network: networks.testnet)
              .data;

      final txb = TransactionBuilder(network: networks.testnet);
      txb.setVersion(1);
      txb.addInput(
        'b39bac02b65af46a49e2985278fe24ca00dd5d627395d88f53e35568a04e10fa',
        0,
        null,
        p2wpkhAlice.output,
      ); // Alice's previous transaction output, has 8746 satoshis
      txb.addInput(
        '46b1f19763ac68e39b8218429f4e29b150f850901562fe44a05fade9e0acd65f',
        1,
        null,
        p2shBob.output,
      ); // Bob's previous transaction output, has 8857 satoshis

      txb.addOutput('2Mv83bPh2HzPRXptuQg9ejbKpSp87Zi52zT', 17000);
      // (in)(8857 + 8746) - (out)(17000) = (fee)603, this is the miner fee

      txb.sign(
          vin: 0,
          keyPair: alice,
          witnessValue:
              8746); // Alice signs her input, which was the first input (0th)
      txb.sign(
          vin: 1,
          keyPair: bob,
          redeemScript: redeemScript,
          witnessValue:
              8857); // Bob signs his input, which was the second input (1th)

      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '01000000000102fa104ea06855e3538fd89573625ddd00ca24fe785298e2496af45ab602ac9bb30000000000ffffffff5fd6ace0e9ad5fa044fe62159050f850b1294e9f4218829be368ac6397f1b1460100000017160014cd5479b8f2ee71037c99b7d864eccbde605adca5ffffffff01684200000000000017a9141f8cc9dfb76a2dd16566fdb05c9c1899be0afbd7870247304402205bead29613536890834a8cb6267ac3f9e3330af40407c6d0c57e3f805eff93bc022067115ce5731de45995c90c3c7c5d71f8bb3b4f7501b2b6268dd4b76da94a57c9012102bdc758cb2fa3153b52d2ec61102cc06ec9a541359c205f83a646a7cf15b3e5f90247304402200a089b72e661402c2812a91baed159a3a633b10b937efbc95512920fd66c2dc90220546c2c73809df80af13824c33a81b639c5e7cd16ccdcb27f1bc4a13217265113012102711353556322a96722f0692ec7b25949417e794169f9c239ee5daa1c9423909900000000');
    });

    test(
        'can create a 2-to-2 (P2SH(P2WPKH) & P2PKH to P2WPKH & P2PKH) Transaction',
        () {
      final bob = ECPair.fromWIF(
          'cVZoW8AdvHpzpN1LQH8x5XoBmefB1b9XmzNKT9STPLmHQLokZF9F',
          network: networks.testnet);
      final p2wpkhBob = P2WPKH(
              data: PaymentData(pubkey: bob.publicKey),
              network: networks.testnet)
          .data;
      final redeemScript = p2wpkhBob.output;
      final p2shBob =
          P2SH(data: PaymentData(redeem: p2wpkhBob), network: networks.testnet)
              .data;

      final charlie = ECPair.fromWIF(
          'cR5kcfNWGV68t4SbGQjwRc9e6rPv58U7KH4sVn6gdmocqcnCZV6K',
          network: networks.testnet);
      final p2pkhCharlie = P2PKH(
        data: PaymentData(pubkey: charlie.publicKey),
        network: networks.testnet,
      ).data;

      final txb = TransactionBuilder(network: networks.testnet);
      txb.setVersion(1);
      txb.addInput(
        'a1127b375250afb23570cbf26e3a1f6c13199acb1563699d799a6e2d05bb6065',
        0,
        null,
        p2pkhCharlie.output,
      ); // Charlie's previous transaction output, has 20000 satoshis
      txb.addInput(
        'bf910b42be814cfb5426b4f6d6d56eb90118bf4dc97d2bfe5e85d8cf8e06cf79',
        1,
        null,
        p2shBob.output,
      ); // Bob's previous transaction output, has 10000 satoshis

      txb.addOutput('mgCvXFKz6GfxCKhVavUskZJwA5hG1BcFCJ', 25000);
      txb.addOutput('tb1qzsg3ttnjpmz797tzqrxgd35s75f2m98xsv3f6g', 4578);
      // (in)(20000 + 10000) - (out)(25000 + 4578) = (fee)422, this is the miner fee

      txb.sign(
          vin: 1,
          keyPair: bob,
          redeemScript: redeemScript,
          witnessValue:
              10000); // Bob signs his input, which was the second input (1th)
      txb.sign(
          vin: 0,
          keyPair: charlie,
          witnessValue:
              20000); // Charlie signs his input, which was the first input (0th)

      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '010000000001026560bb052d6e9a799d696315cb9a19136c1f3a6ef2cb7035b2af5052377b12a1000000006b483045022100fcbce75f1d069bab993f784e7c455522de0204e50ddea51f6bb01d15c2891c6902201f40ac84cd6bde94cd16e32435f033bfcf9fe9269ac7ff2f99ccef2a0e5e202f01210335e51cac96a2ddb00286aee186b1e895021478ef5ae5ca8da0a9699bd4ebb07fffffffff79cf068ecfd8855efe2b7dc94dbf1801b96ed5d6f6b42654fb4c81be420b91bf0100000017160014cd5479b8f2ee71037c99b7d864eccbde605adca5ffffffff02a8610000000000001976a914078f28aa22ee28f0d28514af8c7102bb5d7ef77288ace211000000000000160014141115ae720ec5e2f96200cc86c690f512ad94e60002483045022100d7951a4d66751bc01a26b23f8ef3c47237c330511727e97bd9c89629cc64bb98022062baccc35c52e3f1fcf383a1cf08c10dc140a6f81826ad5d33ae7ed2d37887c2012102711353556322a96722f0692ec7b25949417e794169f9c239ee5daa1c9423909900000000');
    });

    test('can create a 2-to-1 (P2WPKH & P2PKH to P2WPKH) Transaction', () {
      final alice = ECPair.fromWIF(
          'cR6G73NAJjB9SGgf2t4mTDvfer1hmUyRYKS4M5yVnsch5Ee2UmBx',
          network: networks.testnet);
      final p2wpkhAlice = P2WPKH(
              data: PaymentData(pubkey: alice.publicKey),
              network: networks.testnet)
          .data;

      final charlie = ECPair.fromWIF(
          'cR5kcfNWGV68t4SbGQjwRc9e6rPv58U7KH4sVn6gdmocqcnCZV6K',
          network: networks.testnet);
      final p2pkhCharlie = P2PKH(
        data: PaymentData(pubkey: charlie.publicKey),
        network: networks.testnet,
      ).data;

      final txb = TransactionBuilder(network: networks.testnet);
      txb.setVersion(1);
      txb.addInput(
        'ce52e645c3c4a4d3a8adc37192b71f1774c2a6c269e18a46d9e142b0f80d0dbc',
        1,
        null,
        p2wpkhAlice.output,
      ); // Alice's previous transaction output, has 20000 satoshis
      txb.addInput(
        'e6f967cb135e20b642c710714b7e8b6e432181920137f0a39aa6cda9be3c735e',
        0,
        null,
        p2pkhCharlie.output,
      ); // Charlie's previous transaction output, has 150000 satoshis

      txb.addOutput('tb1q4hxl786wlk7q3kyshvqqggp4z4j8mlft7e6h5r', 169500);
      // (in)(20000 + 150000) - (out)(169500) = (fee)500, this is the miner fee

      txb.sign(
          vin: 0,
          keyPair: alice,
          witnessValue:
              20000); // Alice signs her input, which was the first input (0th)
      txb.sign(
          vin: 1,
          keyPair: charlie,
          witnessValue:
              150000); // Charlie signs his input, which was the last input (2nd)

      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '01000000000102bc0d0df8b042e1d9468ae169c2a6c274171fb79271c3ada8d3a4c4c345e652ce0100000000ffffffff5e733cbea9cda69aa3f03701928121436e8b7e4b7110c742b6205e13cb67f9e6000000006a47304402203d197f779df1ea5c877fc219947d2f2e881a48d88895276386fd9a1f5b7f1cb0022004f6b40c7c076058fabef5eb10f2b5caca50830697af228f3d6e4528d0c260cc01210335e51cac96a2ddb00286aee186b1e895021478ef5ae5ca8da0a9699bd4ebb07fffffffff011c96020000000000160014adcdff1f4efdbc08d890bb0004203515647dfd2b0247304402201719ff7b423dc1ff23494d6be8f5d0939dc919d97b1240de1fffaea5510934db0220018daea61f0cd6084edc51ca9517b443900d9d3cc44d2cc083495c9de75ca608012102bdc758cb2fa3153b52d2ec61102cc06ec9a541359c205f83a646a7cf15b3e5f90000000000');
    });
  });
}
