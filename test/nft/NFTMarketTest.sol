// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {console} from "forge-std/console.sol";
import {NFTMarket} from "src/nft/NFTMarket.sol";
import {MyNFT} from "src/nft/MyNFT.sol";
import {BaseERC20} from "src/erc20/BaseERC20.sol";
// openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol
// import {IERC721Errors} "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract NFTMarketTest is Test {
    
    NFTMarket nFTMarket;

    event NftOnList(uint256 tokenId, address seller, uint256 price);

    function setUp() public {}


    // error NotNFTOwner();
    /**
     * 上架NFT：测试上架成功和失败情况，要求断言错误信息和上架事件。
        购买NFT：测试购买成功、自己购买自己的NFT、NFT被重复购买、支付Token过多或者过少情况，要求断言错误信息和购买事件。
        模糊测试：测试随机使用 0.01-10000 Token价格上架NFT，并随机使用任意Address购买NFT
        「可选」不可变测试：测试无论如何买卖，NFTMarket合约中都不可能有 Token 持仓
     */
    // 上架NFT：测试上架成功和失败情况，要求断言错误信息和上架事件。
    function testNFTMarket() public {
        BaseERC20 _erc20 = new BaseERC20();
        MyNFT _nft = new MyNFT("MyNFT", "MYT", "localhost:8080/");
        NFTMarket _market = new NFTMarket(address(_nft), address(_erc20));
        _nft.mintMyNFT(address(this), 1, "a1");
        // 上架NFT：测试上架成功和失败情况，要求断言错误信息和上架事件。
        // 测试上架失败
        vm.startPrank(makeAddr("no_exist_user"));
        vm.expectRevert(NFTMarket.NotNFTOwner.selector);
        _market.list(1, 100);
        vm.stopPrank();
        // 测试上架成功 断言上架事件
        _nft.approve(address(_market), 1);
        vm.expectEmit(true, true, false, true);
        emit NftOnList(1, address(this), 100);
        _market.list(1, 100);
    }

    event Transfer_NFT(address  from, address  to, uint256 tokenId);

    event Refund_Excess_Amount(address  from, address  to, uint256 refund);

    // 购买NFT：测试购买成功、自己购买自己的NFT、NFT被重复购买、支付Token过多或者过少情况，要求断言错误信息和购买事件。
    function testNFTMarketByNFT() public {
        BaseERC20 _erc20 = new BaseERC20();
        MyNFT _nft = new MyNFT("MyNFT", "MYT", "localhost:8080/");
        NFTMarket _market = new NFTMarket(address(_nft), address(_erc20));

        uint256 balance = _erc20.balanceOf(address(this));
        console.log("balanceOf: ", balance);

        address user_AA = makeAddr("user_AA");
        _nft.mintMyNFT(user_AA, 11, "aa1");
        vm.startPrank(user_AA);
        _nft.approve(address(_market), 11);
        _market.list(11, 100);
        vm.stopPrank();
        // 测试购买成功
        _erc20.approve(address(_market), 100);
        vm.expectEmit(true, true, false, true);
        emit Transfer_NFT(user_AA, address(this), 11);
        _market.buyNFT(11);
        address own_nft_11 = _nft.ownerOf(11);
        assertTrue(own_nft_11 == address(this), "own_nft_11 is not this");
        // 测试重复购买nft
        vm.expectRevert(NFTMarket.NFTNotOnList.selector);
        _market.buyNFT(11);
        // 自己购买自己的NFT
        _nft.mintMyNFT(address(this), 1, "a1");
        _nft.mintMyNFT(address(this), 2, "a2");
        _nft.approve(address(_market), 1);
        _market.list(1, 200);
        vm.expectRevert(NFTMarket.AlreadyOwner.selector);
        _market.buyNFT(1);
        // 支付Token过多或者过少情况
        _nft.mintMyNFT(user_AA, 12, "aa2");
        vm.startPrank(user_AA);
        _nft.approve(address(_market), 12);
        _market.list(12, 1000);
        vm.stopPrank();
        // 支付Token过少
        vm.expectRevert("amount is not enougn");
        _erc20.transferWithCallback(address(_market), 900, 12);
        // 支付Token过多
        vm.expectEmit(true, true, false, true);
        emit Refund_Excess_Amount(address(_market), address(this), 100);
        _erc20.transferWithCallback(address(_market), 1100, 12);
        address own_nft_12 = _nft.ownerOf(12);
        assertTrue(own_nft_12 == address(this), "own_nft_12 is not this");
    }

    // 模糊测试：测试随机使用 0.01-10000 Token价格上架NFT，并随机使用任意Address购买NFT
    function testFuzzAmountAndAddress(uint256 amount, address addr) public {
        BaseERC20 _erc20 = new BaseERC20();
        MyNFT _nft = new MyNFT("MyNFT", "MYT", "localhost:8080/");
        NFTMarket _market = new NFTMarket(address(_nft), address(_erc20));
        vm.assume(amount > 0.01 ether && amount < 10000 ether);
        _nft.mintMyNFT(address(this), 1, "a");
        _nft.approve(address(_market), 1);
        _market.list(1, amount);
        // 购买
        _erc20.transfer(addr, amount);
        vm.startPrank(addr);
        _erc20.approve(address(_market), amount);
        _market.buyNFT(1);
        vm.stopPrank();
        assertEq(_nft.ownerOf(1), addr);
    }

    // 不可变测试：测试无论如何买卖，NFTMarket合约中都不可能有 Token 持仓
    function testImmutableTokenBalance() public {
        BaseERC20 _erc20 = new BaseERC20();
        MyNFT _nft = new MyNFT("MyNFT", "MYT", "localhost:8080/");
        NFTMarket _market = new NFTMarket(address(_nft), address(_erc20));

        // 上架并购买 NFT
        _nft.mintMyNFT(address(this), 1, "a1");
        _nft.approve(address(_market), 1);
        _market.list(1, 100);

        address user_AA = makeAddr("user_AA");
        _erc20.transfer(user_AA, 100);
        vm.startPrank(user_AA);
        _erc20.approve(address(_market), 100);
        _market.buyNFT(1);
        vm.stopPrank();
        // 检查 NFTMarket 合约中是否持有 Token
        uint256 marketBalance = _erc20.balanceOf(address(_market));
        assertEq(marketBalance, 0, "NFTMarket contract should not hold any tokens");
    }
    
}
