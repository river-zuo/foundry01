// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyEIP2612Token is ERC20Permit {
    
    constructor() ERC20("MY2612ERC20", "2612ERC") ERC20Permit("MY2612ERC20Permit") {
        _mint(msg.sender, 1e5 * 10 ** decimals());
    }

    function decimals() public view override returns (uint8) {
        return 18;
    }

}


// {
//     "v": 28,
//     "r": "0xb1cec5931eeafc1925b4b0f8dfa55b763858c8735e4249af295be8d951d5fffc",
//     "s": "0x5262df3d6ef8b1ee1086521fcb670ed771859d711763aa9d2d6b98360ef4084d"
// }

// 1747310530
// 1000

// EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)

