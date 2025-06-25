// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/option7/OptionSettlementL1.sol";
import "src/option7/OptionMarketL2.sol";

contract DeployOptionL1 is Script {
    function run() external {
        // Sepolia 私钥和 RPC
        uint256 sepoliaPrivKey = vm.envUint("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        string memory sepoliaRpc = vm.envString("SEPOLIA_RPC_URL");

        // Arbitrum Sepolia 私钥和 RPC
        uint256 arbitrumPrivKey = vm.envUint("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        string memory arbitrumRpc = vm.envString("ARBITRUM_SEPOLIA_RPC_URL");

        // Sepolia 部署 OptionSettlementL1
        vm.rpcUrl(sepoliaRpc);
        vm.startBroadcast(sepoliaPrivKey);

        address sepoliaEndpoint = vm.envAddress("Sepolia_layerzero_address");
        address sepoliaPriceFeed = vm.envAddress("Sepolia_chainlink_EthUsd_address");
        uint16 arbitrumL2ChainId = uint16(vm.envUint("arbitrum_l2_layerzero_chain_id"));
        address marketL2Placeholder = address(0); // 部署后更新

        OptionSettlementL1 settlementL1 = new OptionSettlementL1(
            sepoliaEndpoint,
            sepoliaPriceFeed,
            arbitrumL2ChainId,
            marketL2Placeholder
        );

        vm.stopBroadcast();
        console.log("OptionSettlementL1 deployed at:", address(settlementL1));
    }
}
