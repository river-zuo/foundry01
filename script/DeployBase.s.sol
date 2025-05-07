// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {Base} from "../src/Base.sol";

pragma solidity ^0.8.26;

contract DeployBase is Script {
    function run() external returns (Base) {
        vm.startBroadcast();
        Base constract = new Base();
        console2.log(" contract address", address(constract));
        vm.stopBroadcast();
        return constract;
    }
}