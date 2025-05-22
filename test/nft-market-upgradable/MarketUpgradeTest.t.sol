// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

import "forge-std/Test.sol";

import { NFT } from "src/nft-market-upgradable/NFT.sol";
import { NFTMarketV1 } from "src/nft-market-upgradable/NFTMarketV1.sol";
import { NFTMarketV2 } from "src/nft-market-upgradable/NFTMarketV2.sol";

contract MarketUpgradeTest is Test {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address alice;
    address owner;

    NFT nftImpl;
    NFT nft;
    ERC1967Proxy nftProxy;

    NFTMarketV1 marketV1Impl;
    NFTMarketV2 marketV2Impl;
    NFTMarketV1 market;
    ERC1967Proxy marketProxy;

    function setUp() public {
        owner = address(this);
        alice = vm.addr(1);

        // 部署nft impl and proxy
        nftImpl = new NFT();
        bytes memory nftInit = abi.encodeCall(NFT.initialize, ("TestNFT", "TNFT"));
        nftProxy = new ERC1967Proxy(address(nftImpl), nftInit);
        nft = NFT(address(nftProxy));

        // Mint NFT
        string memory tokenURI = "ipfs://token1";
        nft.mint(alice, tokenURI); // tokenId = 0

        // 部署 market impl and proxy
        marketV1Impl = new NFTMarketV1();
        bytes memory marketInit = abi.encodeCall(NFTMarketV1.initialize, (address(nft)));
        marketProxy = new ERC1967Proxy(address(marketV1Impl), marketInit);
        market = NFTMarketV1(address(marketProxy));
    }

    function testUpgradeAndListWithSignature() public {
        // 升级到V2
        marketV2Impl = new NFTMarketV2();
        market.upgradeToAndCall(address(marketV2Impl), "");

        // 签名
        uint256 tokenId = 0;
        uint256 price = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        bytes32 hash = keccak256(abi.encodePacked(address(market), tokenId, price, deadline));
        bytes32 ethHash = hash.toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, ethHash); // private key of Alice
        bytes memory signature = abi.encodePacked(r, s, v);

        // 授权
        vm.prank(alice);
        nft.setApprovalForAll(address(market), true);

        // 调用 listWithSignature
        vm.prank(alice);
        NFTMarketV2(address(market)).listWithSignature(tokenId, price, deadline, signature);

        // assert
        (address seller, uint256 listedPrice) = NFTMarketV2(address(market)).listings(tokenId);
        assertEq(seller, alice);
        assertEq(listedPrice, price);
        assertEq(nft.ownerOf(tokenId), address(market));
    }
}