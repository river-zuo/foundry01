// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseERC20.sol";

contract TokenBank {

    mapping(address => uint256) public addr_balance;

    BaseERC20 public immutable baseErc20;

    constructor(address erc20Addr) {
        baseErc20 = BaseERC20(erc20Addr);
    }

    // 把erc20合约地址上的token，提取到bank
    function deposit(uint256 amount) public {
        bool success = baseErc20.transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom invoke return false");
        _save(msg.sender, amount);
    }

    function _save(address account, uint256 amount) internal {
        addr_balance[account] += amount;
    }

    // 把用户bank里的token转移到erc20合约中
    function withdraw() public {
        bool success = baseErc20.transfer(msg.sender, addr_balance[msg.sender]);
        require(success, "transfer invoke return false");
        addr_balance[msg.sender] = 0;
    }

}
