// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/option7/OptionSettlementL1.sol";
import "src/option7/OptionMarketL2.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ReadStateL1L2 is Script {
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
        address sepoliaPriceFeed = vm.envAddress("Sepolia_chainlink_EthUsd_address");

        AggregatorV3Interface v3 = AggregatorV3Interface(sepoliaPriceFeed);
        // 获取 ETH/USD 价格，8 decimals，放大到 18 decimals
        (, int256 price,,,) = v3.latestRoundData();
        console.log("price: ", price);
        // 2421.37598600

        address payable settlementL1Address = payable(vm.envAddress("l1Addr"));
        address marketL2 = vm.envAddress("l2Addr");
        OptionSettlementL1 settlementL1 = OptionSettlementL1(settlementL1Address);
        // settlementL1.updateMarketL2(marketL2);
        address marketL2Addr = settlementL1.marketL2();
        // l2ChainId
        uint16 l2ChainId = settlementL1.l2ChainId();
        
        console.log("OptionSettlementL1: marketL2 address", marketL2Addr);
        console.log("OptionSettlementL1: l2ChainId", l2ChainId);

        (address user, uint256 strike, uint256 expiry, uint256 size, uint256 premium, bool exercised) = settlementL1.positions(1);
        console.log("user: ", user);
        console.log("strike: ", strike);
        console.log("expiry: ", expiry);
        console.log("size: ", size);
        console.log("premium: ", premium);
        console.log("exercised: ", exercised);

        // 读取arbitrum usdc banlance
        // IERC20 usdc = IERC20(vm.envAddress("usdc_arbitrum_sepolia_address"));
        // uint256 devKeyBalance = usdc.balanceOf(vm.envAddress("DEV_PUB_KEY"));
        // console.log("devKeyBalance", devKeyBalance);

    }
}