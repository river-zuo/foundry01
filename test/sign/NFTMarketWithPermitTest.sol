// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/sign/NFTMarketWithPermit.sol";
import "../../src/nft/MyNFT.sol";
import "../../src/sign/MyEIP2612Token.sol";
import "forge-std/console.sol";

contract NFTMarketWithPermitTest is Test {
    address constant SIGNER = 0x4251BA8F521CE6bAe071b48FC4621baF621057c5;
    address constant OWNER = 0x4251BA8F521CE6bAe071b48FC4621baF621057c5;

    address constant NFT_OWNER = 0xF764526cc27473A0bebFb228e8757879D4763802;

    function setUp() public {
         // fork sepolia
        string memory sepolia = "https://sepolia.infura.io/v3/f8e482890ce74fa8ab5b5fb9fd31d2c7";
        uint256 forkId = vm.createFork(sepolia);
        vm.selectFork(forkId);
    }

/*
NFT 购买成功的测试日志

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
*/
    function testPermitBuy() public {
        address _marketWithPermit_addr = 0xd155AD1ff981abE77862D89725e4C0Ef27Bb09A8;
        address _nft_addr = 0x3425C9B618c0518470a936ee36e90ea78123aC83;
        address token_addr = 0x32Ae70b4f364775e54741a6d60F0beb8333F2caA;

        NFTMarketWithPermit _market = NFTMarketWithPermit(_marketWithPermit_addr);
        MyNFT _nft = MyNFT(_nft_addr);
        MyEIP2612Token _token = MyEIP2612Token(token_addr);

        vm.startPrank(NFT_OWNER);
        uint256 tokenId = 1;
        address to = NFT_OWNER;
        _nft.mintMyNFT(to, tokenId, "http://test.com");
        _nft.approve(_marketWithPermit_addr, tokenId);
        uint256 _token_price = 666;
        _market.list(tokenId, _token_price);
        address nft_1_owner = _nft.ownerOf(tokenId);
        console.log('before permitBuy, nft, token = 1 owner:', nft_1_owner);
        vm.assertTrue(nft_1_owner == NFT_OWNER, 'nft status error');
        vm.stopPrank();
        vm.startPrank(SIGNER);
        /*
            {
    "v": 28,
    "r": "0x8a7dc4eb507b1fc94bbff3c9383c41434c5f6fe05b70c069e8693cb393659c01",
    "s": "0x4620fd3095e69027603636030c58519ad9e2b2feac58d324afaaff978a9e1c3a"
}
        */
        uint256 deadline = 1747353924;
        uint8 v = 28;
        bytes32 r = 0x8a7dc4eb507b1fc94bbff3c9383c41434c5f6fe05b70c069e8693cb393659c01;
        bytes32 s = 0x4620fd3095e69027603636030c58519ad9e2b2feac58d324afaaff978a9e1c3a;
        _token.approve(_marketWithPermit_addr, _token_price);
        _market.permitBuy(tokenId, deadline, v, r, s);
        nft_1_owner = _nft.ownerOf(tokenId);
        console.log('after permitBuy, nft, token = 1 owner:', nft_1_owner);
        vm.stopPrank();
    }
}


