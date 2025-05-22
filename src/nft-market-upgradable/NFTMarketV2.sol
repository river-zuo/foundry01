pragma solidity ^0.8.0;

import "./NFTMarketV1.sol";
import "./IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract NFTMarketV2 is NFTMarketV1 {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    mapping(bytes32 => bool) public usedSignatures;

    event ListedWithSignature(address seller, address nft, uint256 tokenId, uint256 price);

    function listWithSignature(
        uint256 tokenId,
        uint256 price,
        uint256 deadline,
        bytes memory signature
    ) external {
        require(block.timestamp <= deadline, "Signature expired");

        bytes32 hash = keccak256(abi.encodePacked(address(this), tokenId, price, deadline));
        require(!usedSignatures[hash], "Signature already used");
        usedSignatures[hash] = true;

        address signer = hash.toEthSignedMessageHash().recover(signature);

        require(nft.isApprovedForAll(signer, address(this)), "Not approved");

        nft.transferFrom(signer, address(this), tokenId);
        listings[tokenId] = Listing({ seller: signer, price: price });

        emit ListedWithSignature(signer, address(nft), tokenId, price);
    }
}