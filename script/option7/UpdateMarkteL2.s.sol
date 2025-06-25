// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/option7/OptionSettlementL1.sol";
import "src/option7/OptionMarketL2.sol";

contract UpdateMarkteL2 is Script {
    function run() external {
        // Sepolia 私钥和 RPCs
        uint256 sepoliaPrivKey = vm.envUint("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        string memory sepoliaRpc = vm.envString("SEPOLIA_RPC_URL");

        // Arbitrum Sepolia 私钥和 RPC
        uint256 arbitrumPrivKey = vm.envUint("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        string memory arbitrumRpc = vm.envString("ARBITRUM_SEPOLIA_RPC_URL");

        // ======================
        // 3. 回到 Sepolia 调用 setter，更新 marketL2 地址
        // ======================
        vm.rpcUrl(sepoliaRpc);
        vm.startBroadcast(sepoliaPrivKey);
        
        address payable settlementL1Address = payable(vm.envAddress("l1Addr"));
        address marketL2 = vm.envAddress("l2Addr");
        console.log("L1 Settlement Address: ", settlementL1Address);
        console.log("L2 Market Address: ", marketL2);
        OptionSettlementL1 settlementL1 = OptionSettlementL1(settlementL1Address);
        settlementL1.updateMarketL2(marketL2);

        vm.stopBroadcast();
        console.log("OptionSettlementL1: marketL2 address updated to", address(marketL2));
        
    }
}
