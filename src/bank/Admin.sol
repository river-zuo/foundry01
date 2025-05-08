// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./IBank.sol";

contract Admin {
    
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    // 调用 IBank方法，把资金转入该合约
    function adminWithdraw(IBank bank) external {
        bank.withdraw();
    }

    receive() external payable { }

    // 合约部署者取出将该合约的资金===============================================================

    modifier be_owner_and_has_balance() {
        require(msg.sender == owner, "must_be_owner");
        require(address(this).balance > 0, "must has balance");
        _;
    }

    function withdraw_cur_contract() payable external be_owner_and_has_balance {
        address payable owner_addr = payable(msg.sender);
        owner_addr.transfer(address(this).balance);
    }

    function getOwner() public view returns(address){
        return owner;
    }

}


