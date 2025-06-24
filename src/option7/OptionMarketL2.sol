// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ILayerZeroEndpoint } from "@layerzerolabs/contracts/lzApp/interfaces/ILayerZeroEndpoint.sol";
import { ILayerZeroReceiver } from "@layerzerolabs/contracts/lzApp/interfaces/ILayerZeroReceiver.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OptionMarketL2 is ILayerZeroReceiver, Ownable {
    ILayerZeroEndpoint public endpoint;
    IERC20 public usdc;

    uint16 public dstChainId; // destination chain id (L1 Sepolia)
    address public settlementL1; // address of OptionSettlementL1 on Sepolia

    uint256 public nextTokenId;

    enum OptionStatus { Pending, Exercised, Expired }

    struct Option {
        address user;
        uint256 strike;
        uint256 expiry;
        uint256 size;
        OptionStatus status;
    }

    mapping(uint256 => Option) public options;

    event PositionOpened(address indexed user, uint256 tokenId, uint256 strike, uint256 expiry, uint256 size);
    event ExerciseRequested(address indexed user, uint256 tokenId);
    event ExerciseResultReceived(uint256 tokenId, bool success);

    constructor(address _endpoint, address _usdc, uint16 _dstChainId, address _settlementL1) Ownable(msg.sender) {
        endpoint = ILayerZeroEndpoint(_endpoint);
        usdc = IERC20(_usdc);
        dstChainId = _dstChainId;
        settlementL1 = _settlementL1;
    }

    function openPosition(uint256 strike, uint256 expiry, uint256 size) external payable {
        require(strike > 0 && expiry > block.timestamp && size > 0, "Invalid params");

        uint256 tokenId = nextTokenId++;
        options[tokenId] = Option(msg.sender, strike, expiry, size, OptionStatus.Pending);

        // transfer premium fee from user (e.g., 1% of strike * size) – simplified
        uint256 premium = (strike * size) / 100;
        usdc.transferFrom(msg.sender, address(this), premium);

        // prepare payload
        bytes memory payload = abi.encode(msg.sender, tokenId, strike, expiry, size, premium);

        // send LayerZero message to L1 settlement
        endpoint.send{value: msg.value}(
            dstChainId,
            abi.encodePacked(settlementL1),
            payload,
            payable(msg.sender),
            address(0x0),
            bytes("")
        );

        emit PositionOpened(msg.sender, tokenId, strike, expiry, size);
    }

    function requestExercise(uint256 tokenId) external payable {
        Option storage opt = options[tokenId];
        require(msg.sender == opt.user, "Not owner");
        require(opt.status == OptionStatus.Pending, "Already settled");
        require(block.timestamp >= opt.expiry, "Not expired");

        bytes memory payload = abi.encode(tokenId, opt.user);

        endpoint.send{value: msg.value}(
            dstChainId,
            abi.encodePacked(settlementL1),
            payload,
            payable(msg.sender),
            address(0x0),
            bytes("")
        );

        emit ExerciseRequested(msg.sender, tokenId);
    }

    function lzReceive(
        uint16, bytes calldata, uint64, bytes calldata payload
    ) external override {
        require(msg.sender == address(endpoint), "Only endpoint can call");

        (uint256 tokenId, bool success) = abi.decode(payload, (uint256, bool));
        options[tokenId].status = success ? OptionStatus.Exercised : OptionStatus.Expired;

        emit ExerciseResultReceived(tokenId, success);
    }

    receive() external payable {}
}
