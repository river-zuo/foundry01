// script/Deploy.s.sol
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/nft-upgradeable/MyNFTUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        MyNFTUpgradeable logic = new MyNFTUpgradeable();

        bytes memory initData = abi.encodeWithSignature(
            "initialize(string,string)",
            "MyNFT",
            "MNFT"
        );

        ERC1967Proxy proxy = new ERC1967Proxy(address(logic), initData);

        console2.log("Proxy deployed at:", address(proxy));
        console2.log("Logic deployed at:", address(logic));

        vm.stopBroadcast();
    }
}
// forge script script/DeployV1.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast 
// --verify -vvvv

// nft-upgradeable

// forge script script/nft-upgradeable/Deploy.s.sol --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv

// forge script script/nft-upgradeable/Deploy.s.sol --rpc-url $local --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv

// forge script script/nft-upgradeable/UpgradeToV2.s.sol --rpc-url $local --private-key $local_private_key --broadcast -vvvv

// == Logs ==
//   Proxy deployed at: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
//   Logic deployed at: 0x5FbDB2315678afecb367f032d93F642f64180aa3

// cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url $local
