// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ILayerZeroEndpoint } from "@layerzerolabs/contracts/lzApp/interfaces/ILayerZeroEndpoint.sol";
import { ILayerZeroReceiver } from "@layerzerolabs/contracts/lzApp/interfaces/ILayerZeroReceiver.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
// import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract OptionSettlementL1 is ILayerZeroReceiver, Ownable {
    ILayerZeroEndpoint public endpoint;
    address public marketL2;
    uint16 public l2ChainId;

    AggregatorV3Interface public ethUsdPriceFeed;

    struct Position {
        address user;
        uint256 strike;
        uint256 expiry;
        uint256 size;
        uint256 premium;
        bool exercised;
    }

    mapping(uint256 => Position) public positions;

    event PositionReceived(address indexed user, uint256 tokenId);
    event OptionExercised(uint256 tokenId, address user, uint256 size);
    event OptionExpired(uint256 tokenId);

    constructor(address _endpoint, address _priceFeed, uint16 _l2ChainId, address _marketL2) Ownable(msg.sender) {
        endpoint = ILayerZeroEndpoint(_endpoint);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeed);
        l2ChainId = _l2ChainId;
        marketL2 = _marketL2;
    }

    function updateMarketL2(address _marketL2) external onlyOwner {
        marketL2 = _marketL2;
    }

    function lzReceive(
        uint16 srcChainId,
        bytes calldata fromAddress,
        uint64, // nonce
        bytes calldata payload
    ) external override {
        require(msg.sender == address(endpoint), "Only endpoint");
        require(srcChainId == l2ChainId, "Invalid src chain");

        if (payload.length > 160) {
            // openPosition: address, uint256 x5
            (address user, uint256 tokenId, uint256 strike, uint256 expiry, uint256 size, uint256 premium) = 
                abi.decode(payload, (address, uint256, uint256, uint256, uint256, uint256));

            positions[tokenId] = Position(user, strike, expiry, size, premium, false);
            emit PositionReceived(user, tokenId);
        } else {
            (uint256 tokenId, address user, uint256 usdcPaid) = abi.decode(payload, (uint256, address, uint256));
            _handleExercise(tokenId, user, usdcPaid, fromAddress);
        }
    }

    function _handleExercise(uint256 tokenId, address user, uint256 usdcPaid, bytes calldata fromAddress) internal {
        Position storage pos = positions[tokenId];
        require(!pos.exercised, "Already exercised");
        require(pos.expiry <= block.timestamp, "Not expired yet");
        require(pos.user == user, "Invalid user");

        // 获取 ETH/USD 价格，8 decimals，放大到 18 decimals
        (, int256 price,,,) = ethUsdPriceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        uint256 ethUsdPrice = uint256(price) * 1e10; // 18 decimals

        // strike 是 USDC 6 decimals，size 是 ETH wei（1e18）
        uint256 requiredUsdc = (pos.strike * pos.size) / 1e18; // USDC 6 decimals

        require(usdcPaid >= requiredUsdc, "Insufficient USDC paid");

        // 行权是否“价内”：ETH 当前价格 > 行权价格（注意 strike * 1e12）
        bool success = ethUsdPrice > pos.strike * 1e12;
        if (success) {
            uint256 payout = pos.size;
            require(address(this).balance >= payout, "Insufficient ETH");
            payable(user).transfer(payout);
            emit OptionExercised(tokenId, user, payout);
        } else {
            emit OptionExpired(tokenId);
        }

        pos.exercised = true;

        bytes memory resultPayload = abi.encode(tokenId, success);
        endpoint.send{
            value: address(this).balance / 100
        }(
            l2ChainId,
            abi.encode(marketL2),
            resultPayload,
            payable(address(this)),
            address(0x0),
            bytes("")
        );
    }

    receive() external payable {}
    fallback() external payable {}
}