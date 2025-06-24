// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ILayerZeroEndpoint } from "@layerzerolabs/contracts/lzApp/interfaces/ILayerZeroEndpoint.sol";
import { ILayerZeroReceiver } from "@layerzerolabs/contracts/lzApp/interfaces/ILayerZeroReceiver.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract OptionSettlementL1 is ILayerZeroReceiver {
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

    constructor(address _endpoint, address _priceFeed, uint16 _l2ChainId, address _marketL2) {
        endpoint = ILayerZeroEndpoint(_endpoint);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeed);
        l2ChainId = _l2ChainId;
        marketL2 = _marketL2;
    }

    // Handle message from L2: either openPosition or requestExercise
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
            // string memory fullMsg = string.concat("msg_", Strings.toHexString(user));
            positions[tokenId] = Position(user, strike, expiry, size, premium, false);
            emit PositionReceived(user, tokenId);
        } else {
            // requestExercise: tokenId, user
            (uint256 tokenId, address user) = abi.decode(payload, (uint256, address));
            _handleExercise(tokenId, user, fromAddress);
        }
    }

    function _handleExercise(uint256 tokenId, address user, bytes calldata fromAddress) internal {
        Position storage pos = positions[tokenId];
        require(!pos.exercised, "Already exercised");
        require(pos.expiry <= block.timestamp, "Not expired yet");
        
        string memory name = "Token #";
        string memory fullName = string.concat(name, Strings.toString(tokenId), " ", 
            Strings.toHexString(pos.user), " ",  Strings.toHexString(user));
        require(pos.user == user, fullName);

        (, int256 price,,,) = ethUsdPriceFeed.latestRoundData();
        require(price > 0, "Invalid price");

        bool success = uint256(price) > pos.strike;
        if (success) {
            uint256 payout = pos.size; // 1 ETH per size
            require(address(this).balance >= payout, "Insufficient ETH");
            payable(user).transfer(payout);
            emit OptionExercised(tokenId, user, payout);
        } else {
            emit OptionExpired(tokenId);
        }

        pos.exercised = true;

        // Send result back to L2
        bytes memory resultPayload = abi.encode(tokenId, success);
        endpoint.send{
            value: address(this).balance / 100  // small gas buffer
        }(
            l2ChainId,
            abi.encodePacked(marketL2),
            resultPayload,
            payable(address(this)),
            address(0x0),
            bytes("")
        );
    }

    receive() external payable {}
    fallback() external payable {}
}
