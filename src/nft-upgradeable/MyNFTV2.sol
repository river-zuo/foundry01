// src/MyNFTV2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MyNFTUpgradeable.sol";

contract MyNFTV2 is MyNFTUpgradeable {
    function version() public pure returns (string memory) {
        return "v2";
    }
}

// cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "version()(string)" --rpc-url $local

// cast send <contract-address> "<function-signature>" [args...] --from <sender-address> --private-key <key> --rpc-url <url>

// cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "mint(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --private-key $local_private_key --rpc-url $local

// cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "mint(address)" $local_pub_key --from $local_pub_key --private-key $local_private_key --rpc-url $local

// cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "ownerOf(uint256)" 1 --rpc-url $local
