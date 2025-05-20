// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/bank/Bank.sol";

contract BankTest is Test {
    Bank public bank;

    address internal user1 = address(0x1);
    address internal user2 = address(0x2);
    address internal user3 = address(0x3);
    address internal user4 = address(0x4);
    address internal user5 = address(0x5);
    address internal user6 = address(0x6);
    address internal user7 = address(0x7);
    address internal user8 = address(0x8);
    address internal user9 = address(0x9);
    address internal user10 = address(0x10);
    address internal user11 = address(0x11);

    function setUp() public {
        bank = new Bank();
    }

    function sendEth(address user, uint256 amount) internal {
        vm.deal(user, amount);
        vm.prank(user);
        (bool success, ) = address(bank).call{value: amount}("");
        require(success, "eth send failed");
    }

    function testTop10InsertionAndEviction() public {
        // 用户 1~10 依次存入 1~10 ether
        sendEth(user1, 1 ether);
        sendEth(user2, 2 ether);
        sendEth(user3, 3 ether);
        sendEth(user4, 4 ether);
        sendEth(user5, 5 ether);
        sendEth(user6, 6 ether);
        sendEth(user7, 7 ether);
        sendEth(user8, 8 ether);
        sendEth(user9, 9 ether);
        sendEth(user10, 10 ether);

        address[] memory top = bank.getTop10();
        assertEq(top.length, 10);
        assertEq(top[0], user10); // 最大
        assertEq(top[9], user1);  // 最小

        // 用户11存入11 ether，user1 应该被挤出 Top10
        sendEth(user11, 11 ether);

        address[] memory topAfter = bank.getTop10();
        assertEq(topAfter.length, 10);
        assertEq(topAfter[0], user11);  // user11 变最大
        for (uint i = 0; i < 10; i++) {
            require(topAfter[i] != user1, "user1 should be removed");
        }
    }

    function testUpdateBalanceRerank() public {
        sendEth(user1, 1 ether);
        sendEth(user2, 2 ether);
        sendEth(user3, 3 ether);

        address[] memory before = bank.getTop10();
        assertEq(before[0], user3);

        // user1 再转 5 ether，总余额 6，应该排名第二
        sendEth(user1, 5 ether);

        address[] memory topAfter = bank.getTop10();  // 修改这里
        assertEq(topAfter[0], user1);
    }
}
