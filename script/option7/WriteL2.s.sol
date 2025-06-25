// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/option7/OptionSettlementL1.sol";
import "src/option7/OptionMarketL2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WriteL2 is Script {
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
        IERC20 usdc = IERC20(vm.envAddress("usdc_arbitrum_sepolia_address"));

        address payable settlementL1Address = payable(vm.envAddress("l1Addr"));
        address payable marketL2Addr = payable(vm.envAddress("l2Addr"));
        OptionSettlementL1 settlementL1 = OptionSettlementL1(settlementL1Address);
        OptionMarketL2 marketL2 = OptionMarketL2(marketL2Addr);
        
        uint256 l2BlockTimestamp = marketL2.readBlockTimestamp();

        uint256 strike = 2400e6;
        uint256 expiry = l2BlockTimestamp + 2 minutes;
        uint256 size = 0.00001 ether;

        // 读取arbitrum usdc banlance
        uint256 devKeyBalance = usdc.balanceOf(vm.envAddress("DEV_PUB_KEY"));
        console.log("devKeyBalance", devKeyBalance);
        // 授权转账
        uint256 premium = strike * size / 1e18 / 100;
        usdc.approve(address(marketL2), premium);

        marketL2.openPosition{value: 0.001 ether}(strike, expiry, size);

        
        vm.stopBroadcast();
        console.log("OptionSettlementL1: marketL2 address updated to", address(marketL2));
        
    }
}
