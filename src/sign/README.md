- 调用permitDeposit后, Token 存款成功测试日志
```
❯ forge test --match-contract TokenPermitDepositTest -vv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/sign/TokenPermitDepositTest.sol:TokenPermitDepositTest
[PASS] testPermitDepositWithFork() (gas: 58671)
Logs:
  addr_balance: 2000
  deposit money:  1000
  balance_after: 3000

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 7.04s (2.55s CPU time)

Ran 1 test suite in 7.04s (7.04s CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```

- NFT 购买成功的测试日志
```
❯ forge test --match-contract NFTMarketWithPermitTest -vv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/sign/NFTMarketWithPermitTest.sol:NFTMarketWithPermitTest
[PASS] testPermitBuy() (gas: 238016)
Logs:
  before permitBuy, nft, token = 1 owner: 0xF764526cc27473A0bebFb228e8757879D4763802
  after permitBuy, nft, token = 1 owner: 0x4251BA8F521CE6bAe071b48FC4621baF621057c5

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 11.95s (8.26s CPU time)

Ran 1 test suite in 11.95s (11.95s CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
