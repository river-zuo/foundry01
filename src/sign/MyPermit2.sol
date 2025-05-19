// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "permit2/src/Permit2.sol";

contract MyPermit2 is Permit2{
    constructor() Permit2() {
    }
}
