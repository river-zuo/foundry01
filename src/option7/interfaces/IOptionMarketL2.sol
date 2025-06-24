// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// interface IOptionMarketL2 {
//     struct PositionRequest {
//         address user;
//         uint256 strikePrice;
//         uint256 expiry;
//         uint256 premium;     // 用户支付的 USDC 数量
//         uint256 size;        // ETH 数量（标准单位）
//         uint256 nonce;
//     }

//     /// @notice 用户在 L2 上开仓，生成 NFT，同时向主链发送 settlement 请求
//     function openPosition(PositionRequest calldata req) external;

//     /// @notice 用户在 L2 发起行权请求，消息将发送至主链处理
//     function requestExercise(uint256 tokenId) external;

//     /// @notice 接收主链返回的结算状态（exercise 成功/失败）
//     function onExerciseSettlement(uint256 tokenId, bool success) external;
// }
