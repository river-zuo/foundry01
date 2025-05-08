# 测试NFTMarket
## 测试文件
NFTMarketTest.t.sol
## forge test 执行结果
```
forge test --match-contract NFTMarketTest  -vvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 4 tests for test/nft/NFTMarketTest.sol:NFTMarketTest
[PASS] testByNFT() (gas: 4420745)
Logs:
  balanceOf:  100000000000000000000000000

[PASS] testFuzzAmountAndAddress(uint256,address) (runs: 257, μ: 4062315, ~: 4062315)
[PASS] testImmutableTokenBalance() (gas: 4065829)
[PASS] testNFTMarket() (gas: 4072953)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 575.25ms (576.28ms CPU time)

Ran 1 test suite in 575.87ms (575.25ms CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)
```