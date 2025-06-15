// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "permit2/src/Permit2.sol";
import "src/erc20/BaseERC20.sol";
import "src/sign/TokenBankDepositPermit2.sol";

contract Permit2Test is Test {

    Permit2 public permit2;
    TokenBankDepositPermit2 public depositPermit2;
    BaseERC20 public baseErc20;

    address public owner;

    function setUp() public {
        string memory sepolia = "https://sepolia.infura.io/v3/f8e482890ce74fa8ab5b5fb9fd31d2c7";
        uint256 forkId = vm.createFork(sepolia);
        vm.selectFork(forkId);

        // Initialize Permit2 contract
        owner = makeAddr("testPermit2");
        deal(owner, 1 ether);

        vm.startPrank(owner);
        permit2 = new Permit2();
        baseErc20 = new BaseERC20();
        depositPermit2 = new TokenBankDepositPermit2(address(baseErc20), address(permit2));
        vm.stopPrank();
    }

    function testDepositPermit2() public {
        vm.startPrank(owner);
        // 授权 Permit2 合约使用 BaseERC20 的 token
        uint256 amount = baseErc20.balanceOf(owner);
        baseErc20.approve(address(depositPermit2), amount);
        
        address token = address(baseErc20);
        uint256 transferAmount = 10000;
        uint256 nonce = 0;
        uint256 deadline = block.timestamp + 1 days;

        // bytes memory signature = permit2.getPermitSignature(
        //     owner,
        //     token,
        //     transferAmount,
        //     nonce,
        //     deadline
        // );

        // depositPermit2.depositWithPermit2(token, transferAmount, nonce, deadline, signature);
        // Check the balance in the bank
        assertEq(depositPermit2.addr_balance(owner), transferAmount, "Deposit failed");
        
        vm.stopPrank();
    }

}
