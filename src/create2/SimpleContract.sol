// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleContract {

    uint256 public _pub_val;

    constructor(uint256 _value) {
        _pub_val = _value;
    }

    function setPubVal(uint256 val) public {
        _pub_val = val;
    }

}
