// src/MyNFTUpgradeable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";

// import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// lib/permit2/lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol

// /Users/luck/solidity_project/foundry01/lib/permit2/lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol

contract MyNFTUpgradeable is
    Initializable,
    ERC721Upgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    uint256 public nextTokenId;

    function initialize(string memory name, string memory symbol) public initializer {
        __ERC721_init(name, symbol);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        nextTokenId = 0;
    }

    function mint(address to) public onlyOwner {
        _mint(to, nextTokenId++);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
