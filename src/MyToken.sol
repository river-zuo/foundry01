// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MyToken is ERC20 { 
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _mint(msg.sender, 1e10*1e18);
    } 
}

// forge create --rpc-url <RPC_URL> 
// --private-key <PRIVATE_KEY> 
// <CONTRACT_PATH>:<CONTRACT_NAME>

// forge create --private-key 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6 --rpc-url http://127.0.0.1:8545 --broadcast MyToken --constructor-args "My Token" "MTK"

// forge create --private-key 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6 --rpc-url http://127.0.0.1:8545 --broadcast  MyToken --constructor-args "My Token" "MTK"


// forge create --private-key 2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6 --rpc-url http://127.0.0.1:8545 --broadcast MyToken --constructor-args "My Token" "MTK"

