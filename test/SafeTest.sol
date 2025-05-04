// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.13;

import "forge-std/Test.sol";
import {Safe} from "src/Safe.sol";

contract SafeTest is Test {

    uint32[] public fixtureAmount = [1, 5, 555];

    Safe safe;

    function setUp() public {
        safe = new Safe();
    }

    receive() external payable {}

    function test_withdraw() public {
        payable(address(safe)).transfer(1 ether);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(postBalance, preBalance + 1 ether, "Withdraw get failed");
    }

}
