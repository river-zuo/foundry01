// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/merkletree/AirdopMerkleNFTMarket.sol";
import "src/merkletree/MyERC20Permit.sol";
import "src/merkletree/MyNFT.sol";

contract AirdopMerkleNFTMarketTest is Test {
    MyERC20Permit token;
    MyNFT nft;
    AirdopMerkleNFTMarket market;

    uint256 privateKey = 0xA111111111111111111111111111111111111111111111111111111111111111; // 自定义私钥
    address user = address(0x709fCA731675b619CC24c284eeB5AEF1D7527c77);
    bytes32[] proof;
    uint256 tokenId = 1;
    uint256 price = 1000;

    function setUp() public {
        token = new MyERC20Permit();
        nft = new MyNFT();

        bytes32 leaf = 0x9f7643319513ab39871bbad5878dc46b25f5ce9fc9c665b9c73a50298b88e14b;
        bytes32[] memory leaves = new bytes32[](1);
        leaves[0] = leaf;
        bytes32 root = getRoot(leaves);

        market = new AirdopMerkleNFTMarket(address(token), address(nft), root);

        // Mint token + nft
        token.mint(user, 1000);
        nft.mint(address(market));

        proof = new bytes32[](0);
    }

    function testClaimWithPermitAndMerkle() public {
        vm.startPrank(user);
        uint256 deadline = block.timestamp + 1 days;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            token.getPermitDigest(
                user,
                address(market),
                500,
                token.nonces(user),
                deadline
            )
        );
        // 编码 permitPrePay
        bytes memory permitCall = abi.encodeWithSelector(
            market.permitPrePay.selector,
            user,
            address(market),
            500,
            deadline,
            v,
            r,
            s
        );
        // 编码 claimNFT
        bytes memory claimCall = abi.encodeWithSelector(
            market.claimNFT.selector,
            tokenId,
            price,
            proof
        );

        bytes[] memory calls = new bytes[](2);
        // permitCall, claimCall
        calls[0] = permitCall;
        calls[1] = claimCall;

        console.log("before call, nft_owner", nft.ownerOf(tokenId));
        market.multicall(calls);
        console.log("before call, nft_owner", nft.ownerOf(tokenId));
        assertEq(nft.ownerOf(tokenId), user);
    }

    function getRoot(bytes32[] memory leaves) internal pure returns (bytes32) {
        return leaves[0];
    }

    function _testUse() public {
        address signer = vm.addr(privateKey); // 可选：获取对应地址
        // assertEq(signer, user); // 确保地址一致
        console.log(signer);
    }
}
