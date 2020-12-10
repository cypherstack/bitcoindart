# bitcoinjs
本文主要介绍 `bitcoinjs` 的文件目录和核心数据对象及方法。

## 文件目录说明
- src
  - payments
    - embed.js       // Pay to Data
    - index.js       // payments 入口文件
    - p2ms.js        // Pay to Multiple Signatures
    - p2pk.js        // Pay to Public Key
    - p2pkh.js       // Pay to Public Key Hash
    - p2sh.js        // Pay to Script Hash
    - p2wpkh.js      // Pay to Witness Public Key Hash
    - p2wsh.js       // Pay to Witness Script Hash
  - templates      // 对各种类型 payments 的 input/output 格式检查的方法
  - address.js     // 地址编解码转换方法，包括`Base58Check`、`Bech32`以及Output Script与地址的互转
  - block.js       // 区块处理
  - bufferutils.js // Buffer处理方法
  - classify.js    // 分类方法，对 Output、Input、Witness 进行分类
  - crypto.js      // 加解密库，包括`ripemd160`、`sha1`、`sha256`、`hash160`、`hash256`
  - ecpair.js      // 密钥对处理方法
  - index.js       // 主入口文件
  - networks.js    // 网络编码方式的前缀信息，包括`MainNet`、`TestNet`、`RegTest`等网络
  - psbt.js        // 部分签名比特币交易（Partially Signed Bitcoin Transactions）
  - script_number.js       // 
  - script_signature.js    // 签名序列化(DER)编解码方法
  - script.js              // 脚本编译和反编译方法
  - transaction_builder.js // 交易构建及处理方法
  - transaction.js         // 交易结构体
  - types.js               // 变量类型定义

## 关键数据对象

### Transaction
Transaction 类用于存储完整的交易数据，包括`版本`、`输入交易列表`、`输出交易列表`、`锁定时间`。
#### 属性
- `version` 版本

- `ins` 输入交易列表

  其中，每条输入交易信息的结构如下：
  - `hash` 引用的交易哈希，即 TXID
  - `index` 所引用的交易的输出下标，即 VOUT
  - `script` 输入交易的脚本签名，即 ScriptSig
  - `sequence`
  - `witness` 见证信息

- `outs` 输出交易列表

  其中，每条输出交易信息的结构如下：
  - `value` 输出值
  - `script` 锁定脚本，即 ScriptPubKey

- `locktime` 锁定时间

#### 方法
- static fromBuffer(buffer, _NO_STRICT)
从Buffer导入交易信息

- static fromHex(hex)
从Hex字符串导入交易信息

- addInput(hash, index, sequence, scriptSig)
增加输入交易信息

- addOutput(scriptPubKey, value)
增加输出交易信息

- clone()
克隆交易对象

- hashForSignature(inIndex, prevOutScript, hashType)
获取用于签名的哈希

- hashForWitnessV0(inIndex, prevOutScript, value, hashType) 
获取用于见证的哈希

### TransactionBuilder

#### 属性
- network 网络类型，如 bitcoin、testnet等
- __PREV_TX_SET 所引用的输入交易集，用于判断交易输出被重复引用的问题
- __INPUTS 输入交易列表
- __TX `Transaction` 实例化对象

#### 方法
- static fromTransaction(transaction, network)
通过 Transaction 实例对象创建 TransactionBuilder 实例

- setLockTime(locktime)
设置锁定时间

- setVersion(version)
设置交易版本

- addInput(txHash, vout, sequence, prevOutScript)
添加输入交易

- addOutput(scriptPubKey, value)
添加输出交易

- build()
构建交易信息

- buildIncomplete()
构建交易信息（支持非完整数据）

- sign(signParams, keyPair, redeemScript, hashType, witnessValue, witnessScript)
签名交易

## 关键方法

### expandInput
获取经过扩展了字段信息的交易输入对象

#### 参数
- scriptSig 输入交易的脚本签名
- witnessStack 输入交易的见证信息
- type 输入交易类型
- scriptPubKey 脚本公钥，用于P2MS脚本

#### 返回值
返回值为对象结构，字段如下：
- prevOutScript 所引用交易的输出脚本
- prevOutType 所引用交易的输出脚本类型
- redeemScript 赎回脚本，用于P2SH脚本
- redeemScriptType 赎回脚本类型，用于P2SH脚本
- witnessScript 见证脚本，用于P2SH、P2WSH脚本
- witnessScriptType 见证脚本类型，用于P2SH、P2WSH脚本
- pubkeys 公钥信息（数组）
- signatures 签名信息（数组）
- maxSignatures 签名数量上限，用于P2MS脚本

### expandOutput
获取经过扩展了字段信息的交易输出对象

#### 参数
- script 输出交易锁定脚本
- ourPubKey 公钥

#### 返回值
返回值为对象结构，字段如下：
- type 输出交易类型
- pubkeys 公钥信息（数组）
- signatures 签名信息（空数组），如
：[undefined]
- maxSignatures 签名数量上限，用于P2MS脚本
