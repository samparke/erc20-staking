// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TokenStaking.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MCK") {
        _mint(msg.sender, 100 ether);
    }
}

contract TokenStakingTest is Test {
    TokenStaking public staking;
    MockERC20 public token;
    address owner = address(this);
    address user = makeAddr("user");

    function setUp() public {
        token = new MockERC20();
        staking = new TokenStaking(IERC20(token));

        token.transfer(user, 10 ether);
    }

    // initial tests

    function testRewardsPerHour() public view {
        uint rewardsph = staking.rewardsPerHour();
        assertEq(rewardsph, 1 ether);
    }

    function testInitialStaked() public view {
        uint initialStaked = staking.totalStaked();
        assertEq(initialStaked, 0);
    }

    function testNameAndSymbol() public view {
        string memory name = token.name();
        string memory symbol = token.symbol();

        assertEq(name, "MockToken");
        assertEq(symbol, "MCK");
    }

    function testInitialSupply() public view {
        uint initialSupply = token.totalSupply();
        assertEq(initialSupply, 100 ether);
    }

    function testDeployerBalance() public view {
        uint deployerSupply = token.balanceOf(owner);
        assertEq(deployerSupply, 90 ether);
    }

    function testUserBalance() public view {
        uint userBalance = token.balanceOf(user);
        assertEq(userBalance, 10 ether);
    }

    // test stake

    function testStake() public {
        vm.startPrank(user);

        token.approve(address(staking), 10 ether);
        staking.stake(5 ether);

        assertEq(staking.stakedBalance(user), 5 ether);
        assertEq(staking.totalStaked(), 5 ether);
    }
}
