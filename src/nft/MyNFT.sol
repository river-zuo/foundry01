// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage {

    string baseURI_;
    
    constructor(string memory name_, string memory symbol_, string memory baseUri) ERC721(name_, symbol_) {
        baseURI_ = baseUri;
    }
    
    function _baseURI() internal view override returns (string memory) {
        return baseURI_;
    }
    
    // 铸币
    function mintMyNFT(address to, uint256 tokenId, string memory tokenURI) public  {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }

}

