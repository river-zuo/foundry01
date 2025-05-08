// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Bank} from "src/bank/Bank.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract BankTest is Test {

    // Bank bank;

    function setUp() public {
        // Setup code here
        // bank = new Bank();
    }

    /*
        断言检查存款前后用户在 Bank 合约中的存款额更新是否正确。
        检查存款金额的前 3 名用户时候正确，分别检查有1个、2个、3个、4 个用户，
        以及同一个用户多次存款的情况。
        检查只有管理员可取款，其他人不可以取款。
    */
    function testDeposit() public {
        // console.log("before deposit");
        // console.log(msg.sender);
        // console.log("address this: ", address(this));
        // console.log("start deposit");
        address ua = newAddrWith1Ether("user_AA");
        address ub = newAddrWith1Ether("user_BB");
        address uc = newAddrWith1Ether("user_CC");
        address ud = newAddrWith1Ether("user_DD");
        
        Bank _bank = new Bank();
        address adminAddr = _bank.getAdminAddr();
        console.log("admin addr: ", adminAddr);
        console.log("_bank addr: ", address(_bank));

        address payable _bank_transfer = payable(address(_bank));

        // _bank_transfer.transfer(10); // 会报错, gas不足
        // vm.prank(ua);
        // (bool success, ) = _bank_transfer.call{value: 0.1 ether}("");
        // require(success, "Transfer failed.");
        // ua多次存款
        prank_and_transfer(ua, address(_bank), 0.1 ether);
        prank_and_transfer(ua, address(_bank), 0.1 ether);
        prank_and_transfer(ub, address(_bank), 0.3 ether);
        prank_and_transfer(uc, address(_bank), 0.4 ether);
        prank_and_transfer(ud, address(_bank), 0.5 ether);

        // 以及同一个用户多次存款的情况。
        console.log("bank's balance: ", _bank_transfer.balance);
        console.log("ua's balance: ", ua.balance);
        console.log("ub's balance: ", ub.balance);
        console.log("uc's balance: ", uc.balance);
        console.log("ud's balance: ", ud.balance);
        
        // 断言检查存款前后用户在 Bank 合约中的存款额更新是否正确。
        assertTrue(ua.balance == 1 ether - 0.1 ether - 0.1 ether, "ua's balance is not 0.8 ether");
        assertTrue(ub.balance == 1 ether - 0.3 ether, "ub's balance is not 0.7 ether");
        assertTrue(uc.balance == 1 ether - 0.4 ether, "uc's balance is not 0.6 ether");
        assertTrue(ud.balance == 1 ether - 0.5 ether, "ud's balance is not 0.5 ether");
        assertTrue(address(_bank).balance == 1.4 ether, "ua's balance is not 1.4 ether");
        // 检查前三名
        address[3] memory top_3 = _bank.getTop3();
        assertTrue(top_3[0] == ud, "top 1 addr is not ud");
        assertTrue(top_3[1] == uc, "top 2 addr is not uc");
        assertTrue(top_3[2] == ub, "top 3 addr is not ub");
        prank_and_transfer(ua, address(_bank), 0.6 ether);
        top_3 = _bank.getTop3();
        // 此时最高为ua
        assertTrue(top_3[0] == ua, "top 1 addr is not ua");
        assertTrue(top_3[1] == ud, "top 2 addr is not ud");
        assertTrue(top_3[2] == uc, "top 3 addr is not uc");
        
        vm.prank(ua);
        int8 vv = _bank.withdraw();
        assertTrue(vv == -1, "ua is not admin");
        // 管理员调用
        vm.deal(address(this), 0);
        vv = _bank.withdraw();
        assertTrue(vv == 0, "admin withdraw failed");
        assertTrue(address(this).balance == 2 ether, "admin withdraw failed");
    }

    receive() external payable {
        console.log("receive: ", msg.value);
    }

    function prank_and_transfer(address addr, address bankAddr, uint256 amount) internal {
        vm.prank(addr);
        (bool success, ) = payable(address(bankAddr)).call{value: amount}("");
        require(success, "Transfer failed.");
    }

    function newAddrWith1Ether(string memory addrName) internal returns (address) {
        address ua = makeAddr(addrName);
        vm.deal(ua, 1 ether);
        string memory balance = Strings.toString(uint256(ua.balance));
        Strings.toString(ua.balance);
        console.log("new user addr: ", ua);
        console.log("name: ", addrName);
        console.log("balance: ", balance);
        return ua;
    }

    
}
