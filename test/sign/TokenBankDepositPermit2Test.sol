// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/sign/TokenBankDepositPermit2.sol";
// import "src/sign/MyEIP2612Token.sol";
import "forge-std/console.sol";
import "forge-std/Test.sol";
import "permit2/src/Permit2.sol";
// import "permit2/src/interfaces/IPermit2.sol";
// import "permit2/src/interfaces/ISignatureTransfer.sol";

contract TokenBankDepositPermit2Test is Test {

    // 0xF764526cc27473A0bebFb228e8757879D4763802
    // 0x4251BA8F521CE6bAe071b48FC4621baF621057c5
    address constant owner = 0xF764526cc27473A0bebFb228e8757879D4763802;

    function setUp() public {
        string memory sepolia = "https://sepolia.infura.io/v3/f8e482890ce74fa8ab5b5fb9fd31d2c7";
        uint256 forkId = vm.createFork(sepolia);
        vm.selectFork(forkId);
    }

    function testDepositWithPermit2() public { 
        address erc20Token = 0x32Ae70b4f364775e54741a6d60F0beb8333F2caA;
        address permit2_addr = 0xEdfC81c5326Ab4abDBafF66d09dd1F29ac5BE93F;
        address _tokenBankPermit2_addr = 0xeC848165DCeeb943Dd855CAEe7D3A8AaEb4b27eE;
        // MyEIP2612Token _token = MyEIP2612Token(erc20Token);
        // Permit2 _permit2 = Permit2(permit2_addr);
        TokenBankDepositPermit2 _bankPermit2 = TokenBankDepositPermit2(_tokenBankPermit2_addr);
        uint256 amount = 1000000000000000000;
        uint256 deadline = 1747322749;
        vm.startPrank(owner);
        console.log('balance: ', _bankPermit2.addr_balance(owner));
        // _token.approve(permit2_addr, 10000000000000000000);
        _bankPermit2.depositWithPermit2(
            erc20Token,
            amount,
            0,
            deadline,
            hex"451b85591f0e78df9a2d8a089a335be7cf2da19b5ce108ed8973531e113faef03803fe8a4598e922e99209961cfb57ebe30880cefa99dc737a87eef386e9ff7a1c"
        );
        console.log('balance: ', _bankPermit2.addr_balance(owner));
        assertEq(_bankPermit2.addr_balance(owner), amount);
        vm.stopPrank();
    }

}

// cast decode-calldata 0xa9059cbb0000000000000000000000005494befe3ce72a2ca0001fe0ed0c55b42f8c358f000000000000000000000000000000000000000000000000000000000836d54c


// transfer(address,uint256)
// 0xa9059cbb
// 000000000000000000000000
// 5494befe3ce72a2ca0001fe0ed0c55b42f8c358f000000000000000000000000000000000000000000000000000000000836d54c

// ❯ cast decode-calldata "transfer(address,uint256)" 0xa9059cbb0000000000000000000000005494befe3ce72a2ca0001fe0ed0c55b42f8c358f000000000000000000000000000000000000000000000000000000000836d54c
// 0x5494befe3CE72A2CA0001fE0Ed0C55B42F8c358f
// 137811276 [1.378e8]

