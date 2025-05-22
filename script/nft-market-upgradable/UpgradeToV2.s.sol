// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {NFTMarketV2} from "src/nft-market-upgradable/NFTMarketV2.sol";

interface IUUPSUpgradeable {
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;
}

contract UpgradeToV2 is Script {
    // NFTMarket代理合约地址（NFTMarket Proxy）
    address public constant PROXY_ADDRESS = 0xaFA787acFC3dc959b9846bE494c744a8324eBA1a;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // 部署 V2 实现合约
        NFTMarketV2 marketV2 = new NFTMarketV2();
        console.log("Market V2 implementation deployed at:", address(marketV2));

        // 使用 upgradeToAndCall 升级 Proxy 到新实现，空参数表示不调用初始化函数
        IUUPSUpgradeable(PROXY_ADDRESS).upgradeToAndCall(
            address(marketV2),
            ""
        );

        console.log("Proxy upgraded to V2 at:", PROXY_ADDRESS);

        vm.stopBroadcast();
    }
}

// == Logs ==
//   Market V2 implementation deployed at: 0x9A9f2CCfdE556A7E9Ff0848998Aa4a0CFD8863AE
//   Proxy upgraded to V2 at: 0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1

// forge script script/nft-market-upgradable/UpgradeToV2.s.sol  --rpc-url $local --private-key $local_private_key --broadcast -vvvv

// forge script script/nft-market-upgradable/UpgradeToV2.s.sol  --rpc-url $SEPOLIA_RPC_URL --private-key $ACCOUNT_FOR_DEV_PRIVATE_KEY --broadcast -vvvv

// == Logs == Sepolia
//   Market V2 implementation deployed at: 0xd7b6eeD65Ed98f0f29Ea91aBfB29e5cf7880454C
//   Proxy upgraded to V2 at: 0xaFA787acFC3dc959b9846bE494c744a8324eBA1a
