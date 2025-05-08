// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Bank.sol";

contract BigBank is Bank {
    
    // 最低 0.01ETH
    uint256 private constant LOWEST_SAVE_WEI = 0.001 * 1e18;

    modifier lowest_eth() {
        require(msg.value >= LOWEST_SAVE_WEI, "can't less than 0.01ETH");
        _;
    }

    // 转换新管理员
    function transferAdmin(address new_addr) public isOwner {
        super.setAdminAddr(new_addr);
    }

    receive() external payable lowest_eth override {
        super.recordBalanceOfAddr();
    }

}
