// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyEIP2612Token.sol";

contract TokenBankPermitDeposit {
       bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");


    mapping(address => uint256) public addr_balance;

    MyEIP2612Token public immutable baseErc20;

    constructor(address erc20Addr) {
        baseErc20 = MyEIP2612Token(erc20Addr);
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

     // 支持离线签名授权（permit）进行存款
    function permitDeposit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        // address owner,address spender,uint256 value,uint256 nonce,uint256 deadline
        address owner = msg.sender;
        address spender = address(this);

    //     function permit(
    //     address owner,
    //     address spender,
    //     uint256 value,
    //     uint256 deadline,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) external;
        
        // 授权
        baseErc20.permit(owner, spender, amount, deadline, v, r, s);
        // 存款
        deposit(amount);
    }

}
