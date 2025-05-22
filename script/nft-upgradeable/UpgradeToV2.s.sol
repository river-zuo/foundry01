// script/UpgradeToV2.s.sol
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/nft-upgradeable/MyNFTV2.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IUpgradeable {
    function upgradeTo(address newImplementation) external;
}

// function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
//         _authorizeUpgrade(newImplementation);
//         _upgradeToAndCallUUPS(newImplementation, data);
//     }
interface IUUPSUpgradeable {
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract UpgradeToV2 is Script {
    address public proxyAddress = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512; // ← 填入部署的 Proxy 地址

    function run() external {
        vm.startBroadcast();

        // 1. 部署新逻辑合约 V2
        MyNFTV2 v2 = new MyNFTV2();
        console2.log("New implementation:", address(v2));

        // 2. 升级代理合约到新逻辑地址
        // IUpgradeable(proxyAddress).upgradeTo(address(v2));
        IUUPSUpgradeable(proxyAddress).upgradeToAndCall(address(v2), "");

        vm.stopBroadcast();
    }
}

// cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "ownerOf(uint256)" 1 --rpc-url $local

// forge script script/nft-upgradeable/UpgradeToV2.s.sol --rpc-url $local --private-key $local_private_key --broadcast -vvvv


