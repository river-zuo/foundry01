// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyERC20Permit is ERC20Permit {

    constructor() ERC20("MockToken", "MTK") ERC20Permit("MockToken") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function getPermitDigest(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) external view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                spender,
                value,
                nonce,
                deadline
            )
        );
        return _hashTypedDataV4(structHash);
        // return keccak256(
        //     abi.encodePacked(
        //         "\x19\x01",
        //         DOMAIN_SEPARATOR(),
        //         structHash
        //     )
        // );
    }

}
