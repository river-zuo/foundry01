// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOptionSettlementL1 {
    struct L2PositionMessage {
        address user;
        uint256 tokenId;
        uint256 strikePrice;
        uint256 expiry;
        uint256 size;
        uint256 premium;
        bytes32 l2TxHash; // 可选，用于链间索引绑定
    }

    /// @notice 接收 L2 发来的开仓请求，锁定 ETH、登记仓位状态
    function receiveOpenPosition(L2PositionMessage calldata msg_) external;

    /// @notice 接收 L2 的行权请求，校验价格并发放 ETH
    function settleExercise(uint256 tokenId, address to) external;

    /// @notice 将行权结果（成功/失败）返回 L2 更新状态
    function sendExerciseResult(uint256 tokenId, bool success) external;
}
