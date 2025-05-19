// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../erc20/BaseERC20.sol";
import "permit2/src/Permit2.sol";
import "permit2/src/interfaces/IPermit2.sol";
import "permit2/src/interfaces/ISignatureTransfer.sol";

contract TokenBankDepositPermit2 {

    mapping(address => uint256) public addr_balance;

    BaseERC20 public immutable baseErc20;
    IPermit2 public immutable _permit2;

    constructor(address erc20Addr, address permit2Addr) {
        baseErc20 = BaseERC20(erc20Addr);
        _permit2 = IPermit2(permit2Addr);
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

    /// 使用 Permit2 授权 转账存款
    function depositWithPermit2(
        address token,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) public {
        // 构造 PermitTransferFrom 结构体
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({token: token, amount: amount}),
            nonce: nonce,
            deadline: deadline
        });

        // 构造转账信息
        ISignatureTransfer.SignatureTransferDetails memory transferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: address(this),
            requestedAmount: amount
        });

        // 调用 permit2 合约进行授权+转账
        _permit2.permitTransferFrom(
            permit,
            transferDetails,
            msg.sender,
            signature
        );

        _save(msg.sender, amount);
    }

}

/*
0xa9059cbb0000000000000000000000005494befe3ce72a2ca0001fe0ed0c55b42f8c358f000000000000000000000000000000000000000000000000000000000836d54c
*/
