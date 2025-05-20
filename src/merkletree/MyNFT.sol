// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 public nextId = 1;

    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to) external {
        _mint(to, nextId++);
    }
}
