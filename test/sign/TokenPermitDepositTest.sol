// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "src/sign/MyEIP2612Token.sol";
import "src/sign/TokenBankPermitDeposit.sol";
import "src/nft/MyNFT.sol";


// import "src/sign/TokenBankDepositPermit2.sol";
// import {Permit2} from "permit2/src/Permit2.sol";
// import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";
// import {BaseERC20} from "src/erc20/BaseERC20.sol";
// import {PermitHash} from "permit2/src/libraries/PermitHash.sol";


contract TokenPermitDepositTest is Test {

    address constant SIGNER = 0x4251BA8F521CE6bAe071b48FC4621baF621057c5;

    address constant MYNFT_ADDR = 0x3425C9B618c0518470a936ee36e90ea78123aC83;

    address permit2_addr = 0xEdfC81c5326Ab4abDBafF66d09dd1F29ac5BE93F; // Permit2合约地址


    function setUp() public {
        // fork sepolia
        string memory sepolia = "https://sepolia.infura.io/v3/f8e482890ce74fa8ab5b5fb9fd31d2c7";
        uint256 forkId = vm.createFork(sepolia);
        vm.selectFork(forkId);
        console2.log('forkId:', forkId);
        // permit2 = Permit2(permit2_addr);
    }

    function _testForkSucc() public {
        // 测试是否成功fork
        uint256 blockNumber = vm.activeFork();
        console2.log('blockNumber:', blockNumber);
        assertTrue(blockNumber > 0, "fork failed");

        MyNFT myNFT = MyNFT(MYNFT_ADDR);
        address ownerAddr = myNFT.ownerOf(1);
        console2.log('myNFT ownerAddr:', ownerAddr);

    }

    function testPermit2() public {
        // 测试Permit2合约
        // bytes32 domainSeparator = permit2.DOMAIN_SEPARATOR();
        // console2.log('domainSeparator:', domainSeparator);

        
    }

/*
执行结果日志

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
*/

/*
SIGNER签名信息
{
    "v": 28,
    "r": "0x3c717fd2afca432412da662194583eed9a12e67af27b2f60ac47ed2a307dc62d",
    "s": "0x2a547f504a87febd2b0c68cbf328fd347b02f33eac143ba0c67bac831d1f4d3f"
}
*/
    function _testPermitDepositWithFork() public {
        // sepolia部署的合约地址
        address deposit_addr = 0xE317d04Be77e4D9D96D2442E2B33Afd3D121dE56;
        address token_addr = 0x32Ae70b4f364775e54741a6d60F0beb8333F2caA;

        TokenBankPermitDeposit _deposit = TokenBankPermitDeposit(deposit_addr);
        MyEIP2612Token _token = MyEIP2612Token(token_addr);
        uint256 banlance_before = _deposit.addr_balance(SIGNER);
        // 转账前金额
        console2.log('addr_balance:', banlance_before);
        vm.startPrank(SIGNER);
        // 转账1000个token到deposit合约
        uint256 amount = 1000;
        uint256 deadline = 1747315520;
        uint8 v = 28;
        bytes32 r = 0x3c717fd2afca432412da662194583eed9a12e67af27b2f60ac47ed2a307dc62d;
        bytes32 s = 0x2a547f504a87febd2b0c68cbf328fd347b02f33eac143ba0c67bac831d1f4d3f;
        console2.log('deposit money: ', amount);
        _deposit.permitDeposit(amount, deadline, v, r, s);
        uint256 balance_after = _deposit.addr_balance(SIGNER);
        // 转账后金额
        console2.log('balance_after:', balance_after);
        vm.assertTrue(balance_after == banlance_before + amount, 'amount error');
        vm.stopPrank();
    }

}
