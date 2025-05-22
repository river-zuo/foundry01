pragma solidity ^0.8.0;

import "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./IERC721.sol";

contract NFTMarketV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct Listing {
        address seller;
        uint256 price;
    }

    IERC721 public nft;

    mapping(uint256 => Listing) public listings;

    function initialize(address _nft) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        nft = IERC721(_nft);
    }

    function listNFT(uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be > 0");
        nft.transferFrom(msg.sender, address(this), tokenId);
        listings[tokenId] = Listing({seller: msg.sender, price: price});
    }

    function cancelListing(uint256 tokenId) external {
        Listing memory item = listings[tokenId];
        require(item.seller == msg.sender, "Not seller");
        delete listings[tokenId];
        nft.transferFrom(address(this), msg.sender, tokenId);
    }

    function buyNFT(uint256 tokenId) external payable {
        Listing memory item = listings[tokenId];
        require(item.price > 0, "Not listed");
        require(msg.value == item.price, "Incorrect price");
        delete listings[tokenId];
        payable(item.seller).transfer(msg.value);
        nft.transferFrom(address(this), msg.sender, tokenId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
