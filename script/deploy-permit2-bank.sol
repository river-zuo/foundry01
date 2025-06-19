// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "src/sign/TokenBankDepositPermit2.sol";
import "src/sign/MyPermit2.sol";
import "src/erc20/BaseERC20.sol";

contract DeployPermit2Bank is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ACCOUNT_FOR_DEV_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        BaseERC20 baseERC20 = new BaseERC20();
        address baseERC20_addr = address(baseERC20);
        MyPermit2 myPermit2 = new MyPermit2();
        TokenBankDepositPermit2 myPermit2Bank = new TokenBankDepositPermit2(
            baseERC20_addr,
            address(myPermit2)
        );
        console.log("BaseERC20 address", address(baseERC20));
        console.log("MyPermit2 address", address(myPermit2));
        console.log("MyPermit2Bank address", address(myPermit2Bank));
        vm.stopBroadcast();
    }
}
