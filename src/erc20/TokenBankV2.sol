// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseERC20CallBack.sol";
import "./TokenBank.sol";

contract TokenBankV2 is TokenBank, BaseERC20CallBack {

    constructor(address erc20Addr) TokenBank(erc20Addr) {}

    // 实现存款记录
    function tokensReceived(address account, uint256 amount, bytes calldata data) external override returns (bytes4) {
        require(msg.sender == address(baseErc20), "invoker must be BaseERC20");
        _save(account, amount);
        return BaseERC20CallBack.tokensReceived.selector;
    }

}
