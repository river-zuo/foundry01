- 测试
```
❯ forge test --match-contract AirdopMerkleNFTMarketTest -vvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/merkletree/AirdopMerkleNFTMarketTest.sol:AirdopMerkleNFTMarketTest
[PASS] testClaimWithPermitAndMerkle() (gas: 170404)
Logs:
  before call, nft_owner 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a
  before call, nft_owner 0x709fCA731675b619CC24c284eeB5AEF1D7527c77

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 1.00ms (541.58µs CPU time)

Ran 1 test suite in 120.47ms (1.00ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
