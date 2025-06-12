// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "forge-std/console.sol";
import "src/sign/TokenBankDepositPermit2.sol";
import {Permit2} from "permit2/src/Permit2.sol";
import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";
import {BaseERC20} from "src/erc20/BaseERC20.sol";
import {PermitHash} from "permit2/src/libraries/PermitHash.sol";

// lib/permit2/src/libraries/PermitHash.sol

contract TokenSpenderWithPermit2Test is Test {
    TokenBankDepositPermit2 spender;
    Permit2 permit2;
    BaseERC20 token;
    address owner;
    address recipient;
    uint256 ownerPrivateKey;

    function setUp() public {
        // 创建用户
        recipient = address(0xBEEF);
        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);
        // vm.prank(owner);
        vm.startPrank(owner);

        // 创建 Permit2 和测试 Token
        permit2 = new Permit2();
        token = new BaseERC20();

        spender = new TokenBankDepositPermit2(address(token), address(permit2));

        // 用户授权 Permit2 管理 token
        token.approve(address(permit2), type(uint256).max);
        vm.stopPrank();
    }

    function _testPermitTransfer() public {
        console.log(address(this));
        uint256 amount = 100 ether;
        uint256 nonce = 1;
        uint256 deadline = block.timestamp + 24 hours;
        console.log(deadline);

        // 构造 PermitTransferFrom 和 TransferDetails
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({
                token: address(token),
                amount: amount
            }),
            nonce: nonce,
            deadline: deadline
        });

        ISignatureTransfer.SignatureTransferDetails memory transferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: recipient,
            requestedAmount: amount
        });

        // 构造 EIP-712 签名
        // bytes32 TOKEN_PERMISSIONS_TYPEHASH = keccak256("TokenPermissions(address token,uint256 amount)");
        // bytes32 _TokenPermissions_type_hash = keccak256(abi.encode(
        //             TOKEN_PERMISSIONS_TYPEHASH,
        //             address(token),
        //             amount
        //         ));

        // bytes32 PERMIT_TRANSFER_FROM_TYPEHASH = keccak256(
        //     abi.encodePacked(
        //         "PermitTransferFrom(TokenPermissions permitted,uint256 nonce,uint256 deadline)",
        //         "TokenPermissions(address token,uint256 amount)"
        //     )
        // );

        // bytes32 structHash = keccak256(
        //     abi.encode(
        //         PERMIT_TRANSFER_FROM_TYPEHASH,
        //         _TokenPermissions_type_hash,
        //         nonce,
        //         deadline
        //     )
        // );

        // bytes32 domainSeparator = keccak256(
        //     abi.encode(
        //         keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)"),
        //         keccak256(bytes("Permit2")),
        //         block.chainid,
        //         address(permit2)
        //     )
        // );

        bytes32 structHash = hashPermitTransferFrom(permit);

        bytes32 domainSeparator = permit2.DOMAIN_SEPARATOR();

        // abi.encodePacked("\x19\x01", domainSeparator, structHash)
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        // bytes memory signature = abi.encodePacked(v, s, r);
        // console.log("signature ", signature);
        // console.log("digest ", digest);
        // console.log("domainSeparator ", domainSeparator);
        // console.log("structHash ", structHash);
        
        // console.log("v ", v);
        // console.log("r ", uint256(r));
        // console.log("s ", uint256(s));
        console.log("signature ", signature.length);
        // console.log("signature ", bytes32(signature));
        console.logBytes(signature);
        // cc510ffd34f3d6e2927ded335b19f6c10436391c

        // 调用合约执行 transfer
        address cc = makeAddr("cc");
        // vm.deal(cc, 1 ether);
        console2.log(cc);
        console.log("cc ", cc);
        console.log("spender ", address(spender));
        console.log("permit2 ", address(permit2));
        console.log("token ", address(token));
        console.log("owner ", owner);
        console.log("recipient ", recipient);
        vm.prank(cc);
        // vm.prank(address(cc));
        spender.spendWithPermit(permit, transferDetails, owner, signature);

        // 断言接收人拿到了 token
        assertEq(token.balanceOf(recipient), amount);
    }

     function testPermitTransfer2() public {
        console.log(address(this));
        uint256 amount = 100 ether;
        uint256 nonce = 1;
        uint256 deadline = block.timestamp + 24 hours;
        console.log(deadline);

        // 构造 PermitTransferFrom 和 TransferDetails
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({
                token: address(token),
                amount: amount
            }),
            nonce: nonce,
            deadline: deadline
        });

        ISignatureTransfer.SignatureTransferDetails memory transferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: recipient,
            requestedAmount: amount
        });

        // 构造 EIP-712 签名

        bytes32 structHash = hashPermitTransferFrom(permit);

        bytes32 domainSeparator = permit2.DOMAIN_SEPARATOR();

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        console.log("signature ", signature.length);
        console.logBytes(signature);

        // 调用合约执行 transfer
        address cc = makeAddr("cc");
        // vm.deal(cc, 1 ether);
        console2.log(cc);
        console.log("cc ", cc);
        console.log("spender ", address(spender));
        console.log("permit2 ", address(permit2));
        console.log("token ", address(token));
        console.log("owner ", owner);
        console.log("recipient ", recipient);
        vm.prank(cc);
        // vm.prank(address(cc));
        spender.spendWithPermit(permit, transferDetails, owner, signature);

        // 断言接收人拿到了 token
        assertEq(token.balanceOf(recipient), amount);
    }

// string constant TOKEN_PERMISSIONS_TYPE = "TokenPermissions(address token,uint256 amount)";

// string constant PERMIT_TRANSFER_FROM_TYPE = string(
//     abi.encodePacked(
//         _TRANSFER_FROM_TYPE,
//         TOKEN_PERMISSIONS_TYPE
//     )
// );


    function depositWithPermit2Signature(
        address token,
        uint256 amount,
        uint256 nonce,
        uint256 deadline
    ) public view returns (bytes32) {
        // 构造 PermitTransferFrom 结构体
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({token: token, amount: amount}),
            nonce: nonce,
            deadline: deadline
        });
        hashPermitTransferFrom(permit);
    }

string constant _TRANSFER_FROM_TYPE = "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)";

bytes32 constant TOKEN_PERMISSIONS_TYPEHASH = keccak256(
    "TokenPermissions(address token,uint256 amount)"
);

bytes32 constant PERMIT_TRANSFER_FROM_TYPEHASH = keccak256(
    abi.encodePacked(
        _TRANSFER_FROM_TYPE,
        "TokenPermissions(address token,uint256 amount)"
    )
);

function hashTokenPermissions(ISignatureTransfer.TokenPermissions memory perm) internal pure returns (bytes32) {
    return keccak256(abi.encode(
        TOKEN_PERMISSIONS_TYPEHASH,
        perm.token,
        perm.amount
    ));
}

function hashPermitTransferFrom(ISignatureTransfer.PermitTransferFrom memory permit) internal view returns (bytes32) {
    return keccak256(abi.encode(
        PERMIT_TRANSFER_FROM_TYPEHASH,
        hashTokenPermissions(permit.permitted),
        address(spender),
        permit.nonce,
        permit.deadline
    ));
}

}


// 0x5841210Aa6fa1DB5D5A06d60B624dE688325B18d
// 0xebefb8750e95836f352d084691507b93d15683c2

// PRECOMPILES::ecrecover(0x8d121ba4b36ac39da3472615c07fdbbf27159ad25fa1158b0c634188bf136c2d, 27, 5848766267883202432754488781342831506619834647806624154550753976169611263487, 34681691816755453929842368317364710208444509755624032392236597543488534394347)

