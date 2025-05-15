// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
// import "permit2/src/Permit2.sol";

contract DeployMyPermit2 is Script {
    function run() external {
        vm.startBroadcast();

        // 部署 Permit2 合约
        // Permit2 permit2 = new Permit2();

        // console.log("Permit2 deployed at:", address(permit2));

        vm.stopBroadcast();
    }
}