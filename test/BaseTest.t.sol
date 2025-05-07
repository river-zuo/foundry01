// SPDX-License-Identifier: MIT

import {Test} from "forge-std/Test.sol";
import {Base} from "../src/Base.sol";
import {DeployBase} from "../script/DeployBase.s.sol";

pragma solidity ^0.8.26;

contract BaseTest is Test {
    Base public contractInstance;
    DeployBase public deployer;
    function setUp() public {
        deployer = new DeployBase();
        contractInstance = deployer.run();

    }

    function testExample() public {
        // Add your test logic here
    }
}