// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/option7/OptionSettlementL1.sol";
import "src/option7/OptionMarketL2.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ReadStateL2 is Script {
    function run() external {
        // Sepolia 私钥和 RPCs
        uint256 sepoliaPrivKey = vm.envUint("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        string memory sepoliaRpc = vm.envString("SEPOLIA_RPC_URL");

        // Arbitrum Sepolia 私钥和 RPC
        uint256 arbitrumPrivKey = vm.envUint("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        string memory arbitrumRpc = vm.envString("ARBITRUM_SEPOLIA_RPC_URL");

        // 读取arbitrum usdc banlance
        IERC20 usdc = IERC20(vm.envAddress("usdc_arbitrum_sepolia_address"));
        uint256 devKeyBalance = usdc.balanceOf(vm.envAddress("DEV_PUB_KEY"));
        console.log("devKeyBalance", devKeyBalance);

    }
}