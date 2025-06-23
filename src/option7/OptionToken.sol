// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract OptionToken is ERC721 {
    struct OptionMetadata {
        uint256 strikePrice;
        uint256 expiry;
        uint256 size;
        OptionStatus status;
    }

    enum OptionStatus { Pending, Active, Exercised, Expired }

    mapping(uint256 => OptionMetadata) public optionData;

    function mint(address to, OptionMetadata calldata meta) external;
}
