// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { OptionMarketL2 } from "src/option7/OptionMarketL2.sol";
import { OptionSettlementL1 } from "src/option7/OptionSettlementL1.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

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

contract OptionXTest is Test {
    MockUSDC usdc;
    MockPriceFeed priceFeed;
    OptionMarketL2 market;
    OptionSettlementL1 settlement;

    address alice = address(0xA11CE);
    uint256 ethStrike = 2500e6; // $2500, 6 decimals
    uint256 size = 1 ether;
    // 25 000000 000000000000000000

    function setUp() public {
        usdc = new MockUSDC();
        priceFeed = new MockPriceFeed();

        // mock LayerZero chain ids and endpoints
        address endpoint = address(this);
        address settlementL1 = address(0xBEEF);

        market = new OptionMarketL2(endpoint, address(usdc), 101, settlementL1);
        settlement = new OptionSettlementL1(endpoint, address(priceFeed), 101, address(market));

        // usdc.mint(alice, 10_000e6);
        usdc.mint(alice, 25e8 ether); // 增加铸造数量
        vm.prank(alice);
        usdc.approve(address(market), type(uint256).max);
    }

    function testOpenAndExerciseOption() public {
        vm.startPrank(alice);

        uint256 expiry = block.timestamp + 1 days;
        market.openPosition{value: 0}(ethStrike, expiry, size);

        (address user, uint256 strike,, uint256 _size, OptionMarketL2.OptionStatus status) = market.options(0);
        assertEq(user, alice);
        assertEq(strike, ethStrike);
        assertEq(_size, size);
        assertEq(uint256(status), 0); // Pending

        vm.warp(expiry + 1);
        market.requestExercise(0);
        vm.stopPrank();
    }
}
