- 合约部署地址
```
代理合约地址:
https://sepolia.etherscan.io/address/0xaFA787acFC3dc959b9846bE494c744a8324eBA1a
实现合约MarketV1地址:
https://sepolia.etherscan.io/address/0x3C1896b297655C4b082cf672c1546E6ed445CC3A
实现合约MarketV2地址:
https://sepolia.etherscan.io/address/0xd7b6eeD65Ed98f0f29Ea91aBfB29e5cf7880454C
```
- 合约开源
```
# MarketV1
https://sepolia.etherscan.io/address/0x3C1896b297655C4b082cf672c1546E6ed445CC3A#code
# MarketV2
https://sepolia.etherscan.io/address/0xd7b6eeD65Ed98f0f29Ea91aBfB29e5cf7880454C#code
```
- 测试用例
```
test/nft-market-upgradable/MarketUpgradeTest.t.sol
```
- 日志
```
❯ forge test --match-contract MarketUpgradeTest -vvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/nft-market-upgradable/MarketUpgradeTest.t.sol:MarketUpgradeTest
[PASS] testUpgradeAndListWithSignature() (gas: 1085580)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 7.29ms (1.81ms CPU time)

Ran 1 test suite in 3.09s (7.29ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
