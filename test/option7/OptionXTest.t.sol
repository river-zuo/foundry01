// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { OptionMarketL2 } from "src/option7/OptionMarketL2.sol";
import { OptionSettlementL1 } from "src/option7/OptionSettlementL1.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MockUSDC is IERC20 {
    string public name = "Mock USDC";
    string public symbol = "mUSDC";
    uint8 public decimals = 6;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function transfer(address to, uint256 amount) public returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
        totalSupply += amount;
    }
}

contract MockPriceFeed is AggregatorV3Interface {
    int256 public price = 3000e8; // ETH/USD 3000 * 1e8

    function decimals() external pure override returns (uint8) { return 8; }
    function description() external pure override returns (string memory) { return "MockPrice"; }
    function version() external pure override returns (uint256) { return 1; }
    function getRoundData(uint80) external view override returns (uint80, int256, uint256, uint256, uint80) {
        return (0, price, 0, 0, 0);
    }
    function latestRoundData() external view override returns (uint80, int256, uint256, uint256, uint80) {
        return (0, price, 0, 0, 0);
    }
    function setPrice(int256 _price) external { price = _price; }
}

contract MockEndpoint {
    OptionMarketL2 public market;
    OptionSettlementL1 public settlement;

    function setContracts(OptionMarketL2 _market, OptionSettlementL1 _settlement) external {
        market = _market;
        settlement = _settlement;
    }

    function send(
        uint16, bytes calldata dstAddress, bytes calldata payload,
        address payable, address, bytes calldata
    ) external payable {
        address dst = address(bytes20(dstAddress[:20]));
        if (msg.sender == address(market)) {
            settlement.lzReceive(101, dstAddress, 0, payload);
        } else if (msg.sender == address(settlement)) {
            market.lzReceive(101, dstAddress, 0, payload);
        }
    }
}

contract OptionXTest is Test {
    MockUSDC usdc;
    MockPriceFeed priceFeed;
    OptionMarketL2 market;
    OptionSettlementL1 settlement;
    MockEndpoint endpoint;

    address alice = address(0xA11CE);
    uint256 ethStrike = 2500e6; // $2500, 6 decimals
    uint256 size = 1 ether;

    function setUp() public {
        usdc = new MockUSDC();
        priceFeed = new MockPriceFeed();
        endpoint = new MockEndpoint();

        market = new OptionMarketL2(address(endpoint), address(usdc), 101, address(0xBEEF));
        settlement = new OptionSettlementL1(address(endpoint), address(priceFeed), 101, address(market));

        endpoint.setContracts(market, settlement);

        usdc.mint(alice, 25e8 ether); // 增加铸造数量
        vm.prank(alice);
        usdc.approve(address(market), type(uint256).max);
    }

    function _testOpenAndExerciseOption() public {
        vm.startPrank(alice);

        uint256 expiry = block.timestamp + 1 days;
        market.openPosition{value: 0}(ethStrike, expiry, size);

        (address user, uint256 strike,, uint256 _size, OptionMarketL2.OptionStatus status) = market.options(0);
        assertEq(user, alice);
        assertEq(strike, ethStrike);
        assertEq(_size, size);
        assertEq(uint256(status), 0); // Pending

        vm.warp(expiry + 1);
        // market.requestExercise(0);
        vm.stopPrank();
    }

    function _testRun() public {
        // 0x00000000000000000000000000000000000000000000000000000000000a11ce0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009502f90000000000000000000000000000000000000000000000000000000000000151810000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000000000000000000000014adf4b7320334b9000000
        // 0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a11ce
        bytes memory payload = hex"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a11ce";

        (uint256 tokenId, address user) = abi.decode(payload, (uint256, address));
        console.log("Token ID:", tokenId); // 会输出 0
        console.log("User Address:", user); // 会输出 0xA11cE
    }

    function testCrossChainExerciseSuccess() public {
        vm.startPrank(alice);

        uint256 expiry = block.timestamp + 1 days;
        market.openPosition{value: 0}(ethStrike, expiry, size);

        vm.warp(expiry + 1);
        market.requestExercise(0);
        vm.stopPrank();

        (, , , , , bool exercised) = settlement.positions(0);
        assertTrue(exercised);
    }

    function testCrossChainExerciseFailure() public {
        priceFeed.setPrice(2000e8); // below strike

        vm.startPrank(alice);
        uint256 expiry = block.timestamp + 1 days;
        market.openPosition{value: 0}(ethStrike, expiry, size);
        vm.warp(expiry + 1);
        market.requestExercise(0);
        vm.stopPrank();

        (, , , , , bool exercised) = settlement.positions(0);
        assertTrue(exercised); // marked as processed
    }
    
    
}
