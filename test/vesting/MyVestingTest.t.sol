// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import { MyVesting } from "src/vesting/MyVesting.sol";
import { BaseERC20 } from "src/erc20/BaseERC20.sol";

contract MyVestingTest is Test {

    address deployer;
    address beneficiary;

    BaseERC20 erc20;
    MyVesting vesting;

    uint256 startTime ;

    function setUp() public {
        startTime = block.timestamp;
        beneficiary = address(0xDEAD);
        deployer = address(0xBEEF);
        vm.startPrank(deployer);
        erc20 = new BaseERC20();
        vesting = new MyVesting(beneficiary, address(erc20));
        erc20.transfer(address(vesting), vesting.benifitiary_amount());
        vm.stopPrank();
    }
    
    function testVestingDeployment() public {
        uint256 released = vesting.releasableAmount();
        assertEq(released, 0, "Initial release amount should be zero");
        // 第13个月 1/24 释放
        vm.warp(startTime + 365 days + 31 days);
        released = vesting.releasableAmount();
        assertEq(released, vesting.per_vesting_amount() * 1, "Release amount should be 1/24 of total after 13 months");
        vm.startPrank(beneficiary);
        vesting.release();
        assertEq(erc20.balanceOf(beneficiary), released, "Beneficiary should receive the released amount");
        // 第14个月 2/24 释放
        vm.warp(startTime + 365 days + 31 * 2 days);
        released = vesting.releasableAmount();
        assertEq(released, vesting.per_vesting_amount() * 1, "Release amount should be 2/24 of total after 14 months");
        vesting.release();
        assertEq(erc20.balanceOf(beneficiary), vesting.per_vesting_amount() * 2, "Beneficiary should receive the released amount");
        // 第24个月 24/24 释放
        vm.warp(startTime + 365 days + 31 * 24 days);
        released = vesting.releasableAmount();
        assertEq(released, vesting.benifitiary_amount() , "Release amount should be 12/24 of total after 24 months");
        vesting.release();
        assertEq(erc20.balanceOf(beneficiary), vesting.initial_amount(), "Beneficiary should receive the full amount after 24 months");
        vm.stopPrank();
    }

}
