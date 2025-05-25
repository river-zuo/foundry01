// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 先实现一个 Bank 合约， 用户可以通过 deposit() 存款， 
// 然后使用 ChainLink Automation 、Gelato 或 OpenZepplin Defender Action 
// 实现一个自动化任务， 自动化任务实现：当 Bank 合约的存款超过 x (可自定义数量)时， 
// 转移一半的存款到指定的地址（如 Owner）。
contract Cron_Bank {

    uint256 public threshold;

    address owner;

    constructor (uint256 _s) {
        threshold = _s;
    }

    event receive_balance(address indexed from, uint balance);

    event send_balance(address indexed to, uint balance);

    receive() external payable {
        emit receive_balance(msg.sender, msg.value);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setThreshold(uint256 _s) public onlyOwner {
        threshold = _s;
    }

    function deposit() external payable {
        emit receive_balance(msg.sender, msg.value);
    }

    function cycleCheck() external {
        uint256 balanceOfContract = address(this).balance;
        if (balanceOfContract > threshold) {
            uint256 _thansfer = balanceOfContract / 2;
            address payable p_owner = payable (owner);
            p_owner.transfer(_thansfer);
            emit send_balance(owner, _thansfer);
        }
    }

}
