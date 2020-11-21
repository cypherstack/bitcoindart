## 前言
本文对相关概念的介绍会分成两个部分，分别是原理性说明和代码展示。

## 比特币地址
比特币地址是一个由数字和字母组成的字符串，比特币地址类型分为普通地址和隔离见证（兼容/原生）地址。

下面是比特币地址的示例：
- 普通地址：
1F5VhMHukdnUES9kfXqzPzMeF1GPHKiF64

- 隔离见证（原生）地址：
bc1qnf4kpa62dwhpwm0stsas5yv0skatt3v9s040p8

- 隔离见证（兼容）地址：
33F1CKBVZDDWugFxiaibh9FLtAG6vLyDXk

比特币地址可由公钥经过单向的加密哈希算法得到。由公钥生成比特币地址时使用的算法是Secure Hash Algorithm (SHA)和the RACE Integ rity Primitives Evaluation Message Digest (RIPEMD)，具体地说是SHA256和RIPEMD160。

下面介绍各种类型比特币地址的生成原理。

### 普通地址
#### 步骤1 哈希计算
以公钥 K 为输入，计算其SHA256哈希值，并以此结果计算RIPEMD160 哈希值，得到一个长度为160位（20字节）的数字：

A = RIPEMD160(SHA256(K))

公式中，K是公钥，A是生成的比特币地址。

#### 步骤2 地址编码
通常用户见到的比特币地址是经过“Base58Check”编码的，这种编码使用了58个字符（一种Base58数字系统）和校验码，提高了可读性、避免歧义并有效防止了在地址转录和输入中产生的错误。

为了将数据（数字）转换成Base58Check格式，首先我们要对数据添加一个称作“版本字节”的前缀，这个前缀用来识别编码的数据的类型。比特币普通地址的前缀是`0（十六进制是0x00）`

普通地址 = Base58Check(RIPEMD160(SHA256(K)))
公式中，K是公钥。

普通地址的生成代码
```dart
// 导入 Uint8List
import 'dart:typed_data';
// 导入 SHA256Digest
import 'package:pointycastle/digests/sha256.dart';
// 导入 RIPEMD160Digest
import 'package:pointycastle/digests/ripemd160.dart';
// 导入 bs58check
import 'package:bs58check/bs58check.dart' as bs58check;

Uint8List hash160(Uint8List buffer) {
  Uint8List _tmp = new SHA256Digest().process(buffer);
  return new RIPEMD160Digest().process(_tmp);
}

// 通过公钥计算地址hash
// pubkey：Uint8List 格式的公钥
final hash = hash160(pubkey);
// print(hash);
// [154, 107, 96, 247, 74, 107, 174, 23, 109, 240, 92, 59, 10, 17, 143, 133, 186, 181, 197, 133]，共20字节

// 添加Base58Check版本字节（0x00）
final payload = new Uint8List(21);
payload.buffer.asByteData().setUint8(0, 0x00);
payload.setRange(1, payload.length, hash);
// print(payload);
// [0, 154, 107, 96, 247, 74, 107, 174, 23, 109, 240, 92, 59, 10, 17, 143, 133, 186, 181, 197, 133]

// Base58Check 编码
final address = bs58check.encode(payload);
// print(address);
// 1F5VhMHukdnUES9kfXqzPzMeF1GPHKiF64
```

### 隔离见证（原生）地址
#### 步骤1 哈希计算
该步骤与普通地址一样，即：A = RIPEMD160(SHA256(K))，其中K是公钥，A是生成的比特币地址。

#### 步骤2 地址编码
隔离见证地址使用的是 [Bech32](./bech32.md) 编码方式。Bech32编码实际上由两部分组成：一部分是前缀，被称为HRP（Human Readable Part，用户可读部分），另一部分是特殊的Base32编码，使用字母表`qpzry9x8gf2tvdw0s3jn54khce6mua7l`。比特币隔离见证地址Bech32编码使用的前缀是`bc`，版本号是`0`。

隔离见证地址的生成代码
```dart
// 导入 Segwit
import 'package:bech32/bech32.dart';

// 获取地址 hash 

// Bech32 编码
final address = segwit.encode(Segwit('bc', 0, hash));
// print(address);
// bc1qnf4kpa62dwhpwm0stsas5yv0skatt3v9s040p8
```

### 隔离见证（兼容）地址
> P2SH地址，是采用Base58Check对脚本的20个字节哈希值进行编码，就像比特币地址是公钥20字节哈希的Base58Check编码一样。由于P2SH地址采用5作为前缀，这导致基于Base58编码的地址以“3”开头。

## 附录
### 隔离见证
隔离见证（segwit）是指把特定输出的签名或解锁脚本隔离开。“单独的scriptSig”或“单独的签名”就是它最简单的形式。隔离见证是对比特币的一种架构更改，旨在将见证数据从交易的scriptSig（解锁脚本）字段移动到伴随交易的独立的见证数据结构中。客户端要求的交易数据可以包括见证数据，也可以不包括。