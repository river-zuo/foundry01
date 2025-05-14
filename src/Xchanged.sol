// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Xchanged {

    uint256 public x;

    event XHasChange(uint from, uint to);

    constructor(uint _x) {
        x = _x;
        emit XHasChange(0, _x);
    }

    function setX(uint _x) public {
        emit XHasChange(x, _x);
        x = _x;
    } 

}
