// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/create2/SimpleContract.sol";

contract Create2Test is Test {

    // init_code = 不带构造器的字节码 + 带构造器的字节码
    // 不带构造器的字节码的生成 = type(Contract).creationCode

    SimpleContract simpleContract;

    event _record(bytes _crt_code, bytes _encode, bytes _init_code);

    address constant sender = 0x4251BA8F521CE6bAe071b48FC4621baF621057c5;
    function setUp() public {
        vm.startPrank(sender);
        uint256 _salt = 11;
        simpleContract = new SimpleContract{salt: bytes32(_salt)}(1);
        vm.stopPrank();
        console.log('in setup: ', address(simpleContract));
    }

    // 0x1dFEb23881091B27C09bf6667bb7ddCD09e4918B
    // 0x1dFEb23881091B27C09bf6667bb7ddCD09e4918B
    // 0x1dFEb23881091B27C09bf6667bb7ddCD09e4918B

    function testGen() public {
        uint256 _salt = 11;
        bytes32 salt = bytes32(_salt);

        address res_addr = create2Gen(sender, salt, 1);
        console.log("res_addr: ", res_addr);
    }
    
    function create2Gen(address sender, bytes32 salt, uint256 _value) public returns(address) {
        bytes memory _crt_code = type(SimpleContract).creationCode;
        // console.log("_crt_code: ", _crt_code);
        bytes memory _encode = abi.encode(_value);
        // console.log("_encode: ", _encode);
        bytes memory init_code = abi.encodePacked(_crt_code, _encode);
        // console.log("_crt2_code: ", init_code);
        emit _record(_crt_code, _encode, init_code);
        // return keccak256(abi.encodePacked(0xff, sender, salt, keccak256(init_code)));
        // address = keccak256(0xFF ++ sender ++ salt ++ keccak256(init_code))[12:]
        bytes32 _address_code = keccak256(abi.encodePacked(bytes1(0xff), sender, salt, keccak256(init_code)));
        address deployedAddress = address(uint160(uint256(_address_code)));
        return deployedAddress;
    }
    
}
