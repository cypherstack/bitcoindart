# bitcoinjs
本文介绍 `bitcoinjs` 的

## 文件说明
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