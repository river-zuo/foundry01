// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../erc20/BaseERC20CallBack.sol";
import "./MyNFT.sol";
import "../erc20/BaseERC20.sol";

contract NFTMarket is BaseERC20CallBack {

    mapping(uint256 => uint256) pricesOfNFT;

    NftDetail[] onList;

    // id为0表示移除
    struct NftDetail {
        uint256 id;
        uint256 price;
        address owner;
    }

    MyNFT public immutable _nft;
    BaseERC20 public immutable _erc20;

    event NftOnList(uint256  tokenId, address  seller, uint256 price);

    event Transfer_NFT(address  from, address  to, uint256 tokenId);

    event Refund_Excess_Amount(address  from, address  to, uint256 refund);

    event NFT_Received(address  from, address  to, uint256 tokenId);

    event XHasChange(uint256 indexed i);

    constructor(address nftAddr, address erc20Addr) {
        _nft = MyNFT(nftAddr);
        _erc20 = BaseERC20(erc20Addr);
        emit XHasChange(1);
    }

    // 获取上架列表
    function nftList() public view returns (NftDetail[] memory) {
        return onList;
    }

    // nft价格
    function nftPrice(uint256 tokenId) public view returns (uint256) {
        return pricesOfNFT[tokenId];
    }

    // NFT的持有者上架NFT, 两种实现方式: 1.授权 2.转到该合约
    function list(uint256 tokenId, uint256 amount) public  {
        address owner = _nft.ownerOf(tokenId);
        require(owner != address(0), "nft not exist");
        require(owner == msg.sender, "not the nft holder");
        require(amount > 0, "price must more then zero");
        // 查看NFTMarket是否有授权
        address approveAddr = _nft.getApproved(tokenId);
        require((approveAddr == address(this)), "NFTMarket has not get approved");
        // 上架
        pricesOfNFT[tokenId] = amount;
        
        NftDetail memory detail = NftDetail({
            id: tokenId,
            price: amount,
            owner: owner
        });
        onList.push(detail);
        emit NftOnList(tokenId, msg.sender, amount);
    }

    // 普通的购买 NFT 功能，用户转入所定价的 token 数量，获得对应的 NFT
    function buyNFT(uint256 tokenId) public {
        uint256 price = pricesOfNFT[tokenId];
        require(price > 0, "nft not on list");
        address old_holder = _nft.ownerOf(tokenId);
        address nft_new_holder = msg.sender;
        require(old_holder != nft_new_holder, "you have owned the nft");
        // 转账
        bool success = _erc20.transferFrom(msg.sender, old_holder, price);
        require(success, "thansfer success");
        _nft.transferFrom(old_holder, nft_new_holder, tokenId);
        pricesOfNFT[tokenId] = 0;
        // 移除列表
        _deleteNFTonList(tokenId);
        emit Transfer_NFT(old_holder, nft_new_holder, tokenId);
    }

    // 实现NFT购买功能
    function tokensReceived(address account, uint256 amount, bytes calldata data) external override returns(bytes4) {
        uint256 tokenId = abi.decode(data, (uint256));
        uint256 price = pricesOfNFT[tokenId];
        require(price > 0, "nft not on list");
        require(amount >= price, "amount is not enougn");
        if (amount > price) {
            // 退款
            uint256 refund = amount - price;
            _erc20.transfer(account, refund);
            emit Refund_Excess_Amount(address(this), account, refund);
        }
        address old_holder = _nft.ownerOf(tokenId);
        address nft_new_holder = account;
        _nft.transferFrom(old_holder, nft_new_holder, tokenId);
        emit NFT_Received(old_holder, nft_new_holder, tokenId);
        // 移除列表
        _deleteNFTonList(tokenId);
        return BaseERC20CallBack.tokensReceived.selector;
    }

    function _deleteNFTonList(uint256 tokenId) internal  {
        for (uint256 i=0; i<onList.length;i++) {
            NftDetail memory detail = onList[i];
            if (detail.id == tokenId) {
                detail.id = 0;
                onList[i] = detail;
                break ;
            }
        }
    }

}
