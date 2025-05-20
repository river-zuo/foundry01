// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyERC20Permit.sol";
import "./MyNFT.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract AirdopMerkleNFTMarket {
    MyERC20Permit public token;
    MyNFT public nft;
    bytes32 public merkleRoot;

    mapping(address => bool) public hasClaimed;

    constructor(address _token, address _nft, bytes32 _merkleRoot) {
        token = MyERC20Permit(_token);
        nft = MyNFT(_nft);
        merkleRoot = _merkleRoot;
    }

    function permitPrePay(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        token.permit(owner, spender, value, deadline, v, r, s);
    }

    function claimNFT(
        uint256 tokenId,
        uint256 price,
        bytes32[] calldata proof
    ) external {
        require(!hasClaimed[msg.sender], "Already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(proof, merkleRoot, leaf),
            "Not in whitelist"
        );

        uint256 discounted = price / 2;
        require(
            token.transferFrom(msg.sender, address(this), discounted),
            "Transfer failed"
        );

        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        hasClaimed[msg.sender] = true;
    }

    function multicall(bytes[] calldata data) external {
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Multicall failed");
        }
    }
    
}
