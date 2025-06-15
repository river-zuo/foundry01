// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/sign/TokenBankDepositPermit2.sol";
// import "src/sign/MyEIP2612Token.sol";
import "forge-std/console.sol";
import "forge-std/Test.sol";
import "permit2/src/Permit2.sol";

import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";

import {IEIP712} from "permit2/src/interfaces/IEIP712.sol";

contract TokenBankDepositPermit2Test is Test {

    // 0xF764526cc27473A0bebFb228e8757879D4763802
    // 0x4251BA8F521CE6bAe071b48FC4621baF621057c5
    address constant owner = 0xF764526cc27473A0bebFb228e8757879D4763802;

    address constant SIGNER = 0x4251BA8F521CE6bAe071b48FC4621baF621057c5;

    
    address erc20Token = 0x32Ae70b4f364775e54741a6d60F0beb8333F2caA;
    address permit2_addr = 0xEdfC81c5326Ab4abDBafF66d09dd1F29ac5BE93F; // Permit2合约地址
    address _tokenBankPermit2_addr = 0xeC848165DCeeb943Dd855CAEe7D3A8AaEb4b27eE;
    TokenBankDepositPermit2 _bankPermit2;

    function setUp() public {
        string memory sepolia = "https://sepolia.infura.io/v3/f8e482890ce74fa8ab5b5fb9fd31d2c7";
        uint256 forkId = vm.createFork(sepolia);
        vm.selectFork(forkId);

        _bankPermit2 = new TokenBankDepositPermit2(erc20Token, permit2_addr);
    }

    function testDepositWithPermit2() public { 
        uint256 amount = 1000000000000000000;
        uint256 deadline = block.timestamp + 3600; 
        deal(owner, 1 ether);
        vm.startPrank(owner);
        console.log('balance: ', _bankPermit2.addr_balance(owner));
        bytes32 structHash = depositWithPermit2StructHash(
            erc20Token,
            amount,
            0,
            deadline
        );
        IEIP712 permit2 = IEIP712(permit2_addr);
        bytes32 domainSeparator = permit2.DOMAIN_SEPARATOR();
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );
        bytes32 ownerPrivateKey = vm.envBytes32("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        // console.log('ACCOUNT_FOR_DEV_PRIVATE_KEY', uint256(ownerPrivateKey));
        uint256 tmpKey = uint256(ownerPrivateKey);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(tmpKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // _bankPermit2.depositWithPermit2(
        //     erc20Token,
        //     amount,
        //     0,
        //     deadline,
        //     signature
        // );
        
        // console.log('balance: ', _bankPermit2.addr_balance(owner));
        // assertEq(_bankPermit2.addr_balance(owner), amount);
        // vm.stopPrank();
    }

    function depositWithPermit2StructHash(
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
            address(_bankPermit2),
            permit.nonce,
            permit.deadline
        ));
    }

}
