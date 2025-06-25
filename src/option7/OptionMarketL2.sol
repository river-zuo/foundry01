// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ILayerZeroEndpoint } from "@layerzerolabs/contracts/lzApp/interfaces/ILayerZeroEndpoint.sol";
import { ILayerZeroReceiver } from "@layerzerolabs/contracts/lzApp/interfaces/ILayerZeroReceiver.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OptionMarketL2 is ILayerZeroReceiver, ERC721, Ownable {
    ILayerZeroEndpoint public endpoint;
    address public settlementL1;
    uint16 public l1ChainId;
    IERC20 public usdc;

    enum OptionStatus { Pending, Exercised }

    struct Option {
        uint256 strike;   // USDC strike price, 6 decimals
        uint256 expiry;   // timestamp
        uint256 size;     // ETH amount in wei
        OptionStatus status;
    }

    Option[] public options;

    event PositionOpened(uint256 indexed tokenId, address indexed user);
    event ExerciseRequested(uint256 indexed tokenId, uint256 usdcAmount);

    constructor(address _endpoint, address _usdc, uint16 _l1ChainId, address _settlementL1)
        ERC721("Option7 Position", "OPT7") Ownable (msg.sender)
    {
        endpoint = ILayerZeroEndpoint(_endpoint);
        usdc = IERC20(_usdc);
        l1ChainId = _l1ChainId;
        settlementL1 = _settlementL1;
    }

    function updateSettlementL1(address _settlementL1) external onlyOwner {
        settlementL1 = _settlementL1;
    }

    function readBlockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function openPosition(uint256 strike, uint256 expiry, uint256 size) external payable {
        uint256 premium = strike * size / 1e18 / 100;
        require(usdc.transferFrom(msg.sender, address(this), premium), "Premium transfer failed");
        
        // 构造 payload
        bytes memory payload = abi.encode(msg.sender, options.length, strike, expiry, size, premium);
        // (uint nativeFee,) = endpoint.estimateFees(l1ChainId, settlementL1, payload, false, "");
        // require(msg.value >= nativeFee, "Insufficient native gas fee");

        // 记录仓位 & mint NFT
        options.push(Option(strike, expiry, size, OptionStatus.Pending));
        uint256 tokenId = options.length - 1;
        _mint(msg.sender, tokenId);

        endpoint.send{value: msg.value}(
            l1ChainId,
            abi.encodePacked(settlementL1),
            payload,
            payable(msg.sender),
            address(0),
            ""
        );

        // refund 多余费用
        // if (msg.value > nativeFee) {
        //     payable(msg.sender).transfer(msg.value - nativeFee);
        // }

        emit PositionOpened(tokenId, msg.sender);
    }

    function requestExercise(uint256 tokenId) external payable {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        Option storage opt = options[tokenId];
        require(block.timestamp >= opt.expiry, "Option not expired");
        require(opt.status == OptionStatus.Pending, "Already exercised");

        uint256 usdcAmount = opt.strike * opt.size / 1e18;
        require(usdc.transferFrom(msg.sender, address(this), usdcAmount), "USDC transfer failed");

        bytes memory payload = abi.encode(tokenId, msg.sender, usdcAmount);
        (uint nativeFee,) = endpoint.estimateFees(l1ChainId, settlementL1, payload, false, "");
        require(msg.value >= nativeFee, "Insufficient native gas fee");

        endpoint.send{value: nativeFee}(
            l1ChainId,
            abi.encodePacked(settlementL1),
            payload,
            payable(msg.sender),
            address(0),
            ""
        );

        if (msg.value > nativeFee) {
            payable(msg.sender).transfer(msg.value - nativeFee);
        }

        opt.status = OptionStatus.Exercised;
        emit ExerciseRequested(tokenId, usdcAmount);
    }

    function lzReceive(uint16, bytes calldata, uint64, bytes calldata payload) external {
        (uint256 tokenId, bool success) = abi.decode(payload, (uint256, bool));
        // 可拓展处理结果
    }

    receive() external payable {}
}
