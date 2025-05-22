// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {NFT} from "src/nft-market-upgradable/NFT.sol";
import {NFTMarketV1} from "src/nft-market-upgradable/NFTMarketV1.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployV1 is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // 部署 NFT implementation
        NFT nftImpl = new NFT();
        bytes memory nftInitData = abi.encodeWithSelector(nftImpl.initialize.selector, "UpgradableNFT", "UGNFT");
        ERC1967Proxy nftProxy = new ERC1967Proxy(address(nftImpl), nftInitData);

        // 部署 Market V1 implementation
        NFTMarketV1 marketImpl = new NFTMarketV1();
        bytes memory marketInitData = abi.encodeWithSelector(marketImpl.initialize.selector, address(nftProxy));
        ERC1967Proxy marketProxy = new ERC1967Proxy(address(marketImpl), marketInitData);

        console.log("NFT Proxy deployed to:", address(nftProxy));
        console.log("NFT Impl deployed to:", address(nftImpl));
        console.log("Market Proxy deployed to:", address(marketProxy));
        console.log("Market V1 Impl deployed to:", address(marketImpl));

        vm.stopBroadcast();
    }
}
// forge script script/nft-market-upgradable/DeployV1.s.sol  --rpc-url $local --private-key $local_private_key --broadcast -vvvv

//   NFT Proxy deployed to: 0x9A676e781A523b5d0C0e43731313A708CB607508
//   NFT Impl deployed to: 0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82
//   Market Proxy deployed to: 0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1
//   Market V1 Impl deployed to: 0x0B306BF915C4d645ff596e518fAf3F9669b97016

// forge script script/nft-market-upgradable/DeployV1.s.sol  --rpc-url $local --private-key $local_private_key --broadcast -vvvv

// forge script script/nft-market-upgradable/DeployV1.s.sol  --rpc-url $SEPOLIA_RPC_URL --private-key $ACCOUNT_FOR_DEV_PRIVATE_KEY --broadcast -vvvv

// == Logs == Sepolia
//   NFT Proxy deployed to: 0x37C349e9296F92A42Ad8B3aCb7F805c0f6848fcD
//   NFT Impl deployed to: 0x27cd8cFf3952Ee0cB173931681b004d2F28B2039
//   Market Proxy deployed to: 0xaFA787acFC3dc959b9846bE494c744a8324eBA1a
//   Market V1 Impl deployed to: 0x3C1896b297655C4b082cf672c1546E6ed445CC3A


