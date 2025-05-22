// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract TestSig {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    function recoverSigner(bytes32 hash, bytes memory signature) external pure returns (address) {
        return hash.toEthSignedMessageHash().recover(signature);
    }
}
