// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "src/sign/MyEIP2612Token.sol";
import "src/sign/TokenBankPermitDeposit.sol";

contract TokenPermitDepositTest is Test {

    address constant SIGNER = 0x4251BA8F521CE6bAe071b48FC4621baF621057c5;

    function setUp() public {
        // fork sepolia
        string memory sepolia = "https://sepolia.infura.io/v3/f8e482890ce74fa8ab5b5fb9fd31d2c7";
        uint256 forkId = vm.createFork(sepolia);
        vm.selectFork(forkId);
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
    function testPermitDepositWithFork() public {
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




