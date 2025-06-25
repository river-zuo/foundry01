// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/option7/OptionSettlementL1.sol";
import "src/option7/OptionMarketL2.sol";

contract DeployMarketL2 is Script {
    function run() external {
        // Sepolia 私钥和 RPC
        uint256 sepoliaPrivKey = vm.envUint("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        string memory sepoliaRpc = vm.envString("SEPOLIA_RPC_URL");

        // Arbitrum Sepolia 私钥和 RPC
        uint256 arbitrumPrivKey = vm.envUint("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        string memory arbitrumRpc = vm.envString("ARBITRUM_SEPOLIA_RPC_URL");

        // Arbitrum Sepolia 部署 OptionMarketL2
        vm.rpcUrl(arbitrumRpc);
        vm.startBroadcast(arbitrumPrivKey);

        address arbitrumEndpoint = vm.envAddress("arbitrum_layerzero_sepolia_address");
        address usdcAddress = vm.envAddress("usdc_arbitrum_sepolia_address");
        uint16 sepoliaL1ChainId = uint16(vm.envUint("Sepolia_l1_layerzero_chain_id"));
        address settlementL1Address = address(vm.envAddress("l1Addr"));
        console.log("L1 Settlement Address: ", settlementL1Address);

        OptionMarketL2 marketL2 = new OptionMarketL2(
            arbitrumEndpoint,
            usdcAddress,
            sepoliaL1ChainId,
            settlementL1Address
        );

        vm.stopBroadcast();
        console.log("OptionMarketL2 deployed at:", address(marketL2));
        
    }
}
