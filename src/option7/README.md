# 一个可跨链的看涨期权

```
用户调用 openPosition() ⟶ L2 OptionMarket
                        ⟶ sendMessage 到主链
                                ⟶ L1 OptionSettlement 接收消息并锁定 ETH
                                ⟶ 回传状态给 L2 更新 NFT 状态
```

```
重要设计注意点
使用 nonce 避免消息重放

使用 CrossChainMessenger 抽象通信逻辑，便于支持其他协议（如 CCIP）

所有资产实际只在 L1 进行结算与交付，L2 合约只做逻辑驱动与凭证 mint

用户只能在 仓位到期当天 在 L2 发起行权（避免早行权）
```

