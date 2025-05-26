// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract MyVesting {
    
    address public beneficiary;

    address public lockedErc20;

    // cliff 持续时间
    uint256 public cliff;

    // 持续时间
    uint256 public vesting_duration;

    // 合约部署时间
    uint256 public deploy_time;

    uint256 public benifitiary_amount;

    uint256 public constant initial_amount = 1e6 * 1e18;

    uint256 public constant vesting_times = 24;

    uint256 public per_vesting_amount;

    uint256 public has_vesting_times = 0;

    constructor(address _beneficiary, address _lockedErc20) payable {
        deploy_time = block.timestamp;
        cliff = 365 * 24 * 3600;
        vesting_duration = 2 * 365 * 24 * 3600;
        // 转入100万 ERC20, 并开始计算cliff
        benifitiary_amount = initial_amount;
        per_vesting_amount = benifitiary_amount / vesting_times;
        // IERC20(_lockedErc20).transfer(address(this), benifitiary_amount);
        beneficiary = _beneficiary;
        lockedErc20 = _lockedErc20;
    }

    // 释放
    function release() public {
        require(msg.sender == beneficiary, "Only beneficiary can release");
        uint256 releasable_amount = releasableAmount();
        require(releasable_amount > 0, "No releasable amount");

        require(benifitiary_amount >= 0, "Insufficient balance to release");
        benifitiary_amount -= releasable_amount;
        has_vesting_times = (initial_amount - benifitiary_amount) / per_vesting_amount;
        // 转账给受益人
        IERC20(lockedErc20).transfer(beneficiary, releasable_amount);
    }

    // 计算当前可释放的金额
    function releasableAmount() public view returns (uint256) {
        uint256 current_time = block.timestamp;
        if (current_time < deploy_time + cliff) {
            return 0; // 在 cliff 期间不可释放
        }
        uint256 elapsed_time = current_time - (deploy_time + cliff);
        if (elapsed_time >= vesting_duration) {
            return benifitiary_amount; // 全部可释放
        }
        if (elapsed_time <= 0) {
            return 0; // 没有可释放的时间段
        }
        // 单次释放的持续时间段
        uint256 per_vesting_duration = vesting_duration / vesting_times;
        uint256 can_vesting_times = elapsed_time / per_vesting_duration;
        if ((can_vesting_times - has_vesting_times) <= 0) {
            return 0; // 没有新的可释放时间段
        }
        uint256 can_released = (can_vesting_times - has_vesting_times) * per_vesting_amount;
        return can_released > benifitiary_amount ? benifitiary_amount : can_released;
    }


}
