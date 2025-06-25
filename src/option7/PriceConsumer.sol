// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract PriceConsumer {
    AggregatorV3Interface public ethUsdPriceFeed;

    constructor(address _priceFeed) {
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeed);
    }

    /// @notice 获取 ETH/USD 最新价格，返回值已调整为 18 decimals
    function getLatestEthUsdPrice() public view returns (uint256) {
        (
            , 
            int256 price,
            ,
            ,
        ) = ethUsdPriceFeed.latestRoundData();
        require(price > 0, "Invalid price data");

        // Chainlink ETH/USD 预言机默认返回的是 8 decimals，比如 3250.00000000 => 325000000000
        // 为了统一，扩展到18 decimals，方便与其他18 decimals token计算
        return uint256(price) * 1e10;
    }

    /// @notice 计算用户需支付的 USDC 数量（6 decimals）
    /// @param strikePrice 行权价，单位为 USD * 1e18 （统一18 decimals）
    /// @param size ETH 数量，单位 wei (1e18)
    /// @return usdcAmount 需支付的 USDC 数量，6 decimals
    function calculateUsdcAmount(uint256 strikePrice, uint256 size) public pure returns (uint256) {
        // strikePrice: USD with 18 decimals
        // size: ETH wei (1e18)
        // 计算公式: strikePrice * size / 1e18，结果是 USD with 18 decimals

        uint256 usdcAmount18 = (strikePrice * size) / 1e18;

        // 将18 decimals 换算成 USDC 6 decimals，需除以 1e12
        return usdcAmount18 / 1e12;
    }
}
