// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseERC20CallBack.sol";

contract BaseERC20 {
    string public name;
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor()  {
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 1e8 * 1e18;
        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(_to, _value);
        return true;
    }

    function _transfer(address _to, uint256 _value) internal {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);  
    }

    // 在转账时，如果目标地址是合约地址的话，调用目标地址的 tokensReceived() 方法
    function transferWithCallback(address _to, uint256 _value, uint256 tokenId) public returns (bool success) {
        _transfer(_to, _value);
        // 目标地址是合约地址
        if (_to.code.length > 0) {
            BaseERC20CallBack callback = BaseERC20CallBack(_to);
            bytes memory encodedTokenId = abi.encode(tokenId); // 将 uint256 编码为 bytes
            try callback.tokensReceived(msg.sender, _value, encodedTokenId) returns (bytes4 res) {
                return BaseERC20CallBack.tokensReceived.selector == res;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non BaseERC20CallBack implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        balances[_from] -= _value;
        balances[_to] += _value;
        uint256 curAllow = allowance(_from, msg.sender);
        require(curAllow >= _value, "ERC20: transfer amount exceeds allowance");
        allowances[_from][msg.sender] = curAllow - _value;
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        return allowances[_owner][_spender];
    }
}