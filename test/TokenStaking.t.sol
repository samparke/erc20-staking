// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TokenStaking.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockStakeERC20 is ERC20 {
    constructor() ERC20("MockStakeToken", "MST") {
        _mint(msg.sender, 100 ether);
    }
}

contract MockRewardERC20 is ERC20 {
    constructor() ERC20("MockRewardToken", "MRT") {
        _mint(msg.sender, 100 ether);
    }
}

contract TokenStakingTest is Test {
    TokenStaking public stakingContract;

    MockStakeERC20 public stakingToken;
    MockRewardERC20 public rewardsToken;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    event Staked(address indexed user, uint256 amount);

    function setUp() public {
        stakingToken = new MockStakeERC20();
        rewardsToken = new MockRewardERC20();

        vm.prank(owner);
        stakingContract = new TokenStaking(
            address(stakingToken),
            address(rewardsToken)
        );

        stakingToken.transfer(user, 100 ether);
    }

    function testTokenNames() public view {
        string memory stakeName = stakingToken.name();
        string memory rewardName = rewardsToken.name();

        assertEq(stakeName, "MockStakeToken");
        assertEq(rewardName, "MockRewardToken");
    }

    function testStakeContractOwner() public view {
        assertEq(stakingContract.owner(), owner, "not the owner");
    }
}
