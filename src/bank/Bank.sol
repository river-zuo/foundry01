// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./IBank.sol";

contract Bank is IBank {
    // 记录每个合约地址的存款金额
    mapping(address => uint256) public addr_balance;
    // 存款最高的前三名
    address[3] private top_3_balance_addr;
    // 管理员地址
    address private admin_addr;
    // 未初始化时的地址
    address private constant UN_INIT_ADDR = 0x0000000000000000000000000000000000000000;

    constructor() {
        admin_addr = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == admin_addr, "must be owner");
        _;
    }

    modifier need_more_than_zero() {
        require(msg.value > 0, "need msg.value > 0");
        _;
    }

    function getAdminAddr() public view returns(address) {
        return admin_addr;
    }

    function setAdminAddr(address new_addr) internal isOwner {
        admin_addr = new_addr;
    }

    // 接受转账
    receive() external payable virtual {
        recordBalanceOfAddr();
    }

    // 管理员可以通过该方法提取所有的资金
    function withdraw() external payable override returns(int8) {
        address payable addr = payable(address(msg.sender));
        // 是否为管理员地址
        if (addr != admin_addr) {
            return -1;
        }
        address payable this_addr = payable(address(this));
        uint256 balance = this_addr.balance;
        if (balance > 0) {
            addr.transfer(balance);
        } else {
            // 没有余额
            return -2;
        }
        return 0;
    }

    function recordBalanceOfAddr() internal {
        bool has_record = addr_balance[msg.sender] > 0;
        // 入账
        addr_balance[msg.sender] += msg.value;
        // 记录最高的三个地址
        (uint256 lowest, ) = lowest_balance_in_top3();
        if (lowest == 0 && !has_record) {
            init_top3();
        } else if (addr_balance[msg.sender] > lowest) {
            // 替换最小值对应的地址
            // for (uint i = 0; i < top_3_balance_addr.length; i++) {
            //     if (top_3_balance_addr[i] == lowest_addr) {
            //         top_3_balance_addr[i] = msg.sender;
            //     }
            // }
            top_3_balance_addr[2] = msg.sender;
            // 排序
            sortTop3();
        }
    }

    function sortTop3() private {
        for (uint i = 0; i < top_3_balance_addr.length; i++) {
            for (uint j = i + 1; j < top_3_balance_addr.length; j++) {
                if (addr_balance[top_3_balance_addr[i]] < addr_balance[top_3_balance_addr[j]]) {
                    address temp = top_3_balance_addr[i];
                    top_3_balance_addr[i] = top_3_balance_addr[j];
                    top_3_balance_addr[j] = temp;
                }
            }
        }
    }

    function getTop3() public view returns(address[3] memory) {
        return top_3_balance_addr;
    }

    function lowest_balance_in_top3() private need_more_than_zero returns(uint256, address) {
        // uint256 lowest = addr_balance[top_3_balance_addr[0]];
        // address lowest_addr = top_3_balance_addr[0];
        // for (uint i = 0; i < top_3_balance_addr.length; i++) {
        //     if (lowest > addr_balance[top_3_balance_addr[i]]) {
        //         lowest = addr_balance[top_3_balance_addr[i]];
        //     }
        // }
        // return (lowest, lowest_addr);
        return (addr_balance[top_3_balance_addr[2]], top_3_balance_addr[2]);
    }

    function init_top3() private {
        for (uint i = 0; i< top_3_balance_addr.length;i++) {
            if (top_3_balance_addr[i] == UN_INIT_ADDR) {
                top_3_balance_addr[i] = msg.sender;
                break ;
            }
        }
        sortTop3();
    }

    // 向合约转账, remix中测试使用
    // function transferTocontract() external payable {
    //     address payable addr = payable(address(this));
    //     addr.transfer(msg.value);
    //     recordBalanceOfAddr();
    // }

}
