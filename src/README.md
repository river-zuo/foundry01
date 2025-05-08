# week1day4
- Sepolia测试网
- BigBank合约地址 0xD1a57a15307E277c3443d2c020ea16A594cA5d9D
- Admin合约地址 0xcc63a6E9DCa852d1Ab332f7F3F4A08153809112E

- 管理员权限转移到Admin合约地址。 交易hash: https://sepolia.etherscan.io/tx/0xbdcfe71e86a8121ed335f832bee1e166f6a0fb3613250f1c40c54d3c6d8a3737
- 账户1向Bigbank地址存款0.002eth。 交易hash: https://sepolia.etherscan.io/tx/0xa3628d47302eae2f3bdd3ea1243f81bec4b83296d7362b702f9e2167522825e5
- 账户2向Bigbank合约存储0.0011eth。 交易hash: https://sepolia.etherscan.io/tx/0x1fc5869df8629cf403e2939d24a5af7388fbb6ad7f827dfa560ea6aa3e414e21
- 账户3向Bigbank合约存款0.0012eth。交易hash: https://sepolia.etherscan.io/tx/0x8b218fe5c12c7c7e8621a8e94887ceb719f7da9c33acf02024d623e94c027e3d
- 账户4向Bigbank合约存款0.003eth。交易hash: https://sepolia.etherscan.io/tx/0x8dd7b10d45190b116f516d05dd3d9394dfc4105b045809f4ba69b736c3fce4a5
- Admin合约从Bigbank合约提取资金。交易hash: https://sepolia.etherscan.io/tx/0xda835a96876994d4b54732dac90d1ae80b78ca6abcfffea3615047bd9c09ba62
- 管理员从Admin合约提取资金。交易hash: https://sepolia.etherscan.io/tx/0xdf4d430a56cc6c3680def56fa47b812814786a99d0b1e08af11265f243570ed4

```
在 该挑战 的 Bank 合约基础之上，编写 IBank 接口及BigBank 合约，使其满足 Bank 实现 IBank， BigBank 继承自 Bank ， 同时 BigBank 有附加要求：要求存款金额 >0.001 ether（用modifier权限控制）BigBank 合约支持转移管理员编写一个 Admin合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , adminWithdraw 中会调用 IBank接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址，模拟几个用户的存款，然后Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。请提交 github 仓库地址。
```