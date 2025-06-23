// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract CrossChainMessenger {
    function sendMessage(
        uint16 dstChainId,
        bytes calldata payload
    ) internal virtual;

    function receiveMessage(
        uint16 srcChainId,
        bytes calldata payload
    ) external virtual;
}
