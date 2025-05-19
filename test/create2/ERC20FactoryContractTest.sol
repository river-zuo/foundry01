pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "src/create2/CloneFactory.sol";
import "src/create2/ERC20FactoryContract.sol";
import "src/create2/BaseERC20Template.sol";

contract ERC20FactoryContractTest is Test {

    ERC20FactoryContract _factory;
    BaseERC20Template baseERC20Template;
    address deployer;

    uint256 constant COMMENSSION = 10;
    function setUp() public {
        deployer =  makeAddr("deploer");
        vm.deal(deployer, 1 ether);
        vm.startPrank(deployer);
        baseERC20Template = new BaseERC20Template();
        _factory = new ERC20FactoryContract(address(baseERC20Template), COMMENSSION);
        vm.stopPrank();
    }

    function testDeployAndMint() public {
        address creator = makeAddr("erc20_creator");
        vm.deal(creator, 1 ether);
        vm.prank(creator);
        uint256 perMint = 100;
        address _erc20_clone_addr =_factory.deployInscription("TEST", 1000000, perMint, 50);
        address minter = makeAddr("minter");
        vm.startPrank(minter);
        vm.deal(minter, 1 ether);
        uint256 tranferValue = 50;
        _factory.mintInscription{value: tranferValue}(_erc20_clone_addr);
        vm.stopPrank();
        assertEq(address(_factory).balance, COMMENSSION);
        assertEq(address(minter).balance, 1 ether - tranferValue);
        assertEq(address(creator).balance, 1 ether + (tranferValue - COMMENSSION));
        assertEq(BaseERC20Template(_erc20_clone_addr).balanceOf(address(minter)), perMint);
        console.log("erc20 factory balance: ", address(_factory).balance);
        console.log("minter balance: ", minter.balance);
        console.log("creator balance: ", creator.balance);
        console.log("minter token: ", BaseERC20Template(_erc20_clone_addr).balanceOf(address(minter)));
    }

}
