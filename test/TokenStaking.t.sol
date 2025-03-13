// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TokenStaking.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockStakeERC20 is ERC20 {
    constructor() ERC20("MockStakeToken", "MST") {
        _mint(msg.sender, 20 ether);
    }
}

contract MockRewardERC20 is ERC20 {
    constructor() ERC20("MockRewardToken", "MRT") {
        _mint(msg.sender, 20 ether);
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
        stakingContract = new TokenStaking(address(stakingToken), address(rewardsToken));

        stakingToken.transfer(user, 10 ether);
        rewardsToken.transfer(address(stakingContract), 10 ether);

        vm.startPrank(owner);
        stakingContract.setRewardDuration(10 days);
        stakingContract.notifyRewardAmount(0.001 ether);
        vm.stopPrank();
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

    function testRewardDuration() public view {
        uint256 rewardDuration = stakingContract.duration();
        assertEq(rewardDuration, 10 days);
    }

    function testInitialFinishAtDuration() public view {
        uint256 rewardDuration = stakingContract.duration();
        uint256 finishAt = stakingContract.finishAt();
        uint256 buffer = 2;

        assertGt(finishAt, rewardDuration - buffer);
        assertLt(finishAt, rewardDuration + buffer);
    }

    function testUpdatedAt() public view {
        uint256 updatedAt = stakingContract.updatedAt();
        assertEq(updatedAt, block.timestamp);
    }

    function testUserStakingTokenBalance() public view {
        uint256 userStakingTokenBalance = stakingToken.balanceOf(user);
        assertEq(userStakingTokenBalance, 10 ether);
    }

    function testTotalStaked() public {
        vm.startPrank(user);
        stakingToken.approve(address(stakingContract), 10 ether);
        stakingContract.stake(5 ether);

        assertEq(stakingContract.totalStaked(), 5 ether);
        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(user);
        stakingToken.approve(address(stakingContract), 10 ether);
        stakingContract.stake(5 ether);
        assertEq(stakingContract.totalStaked(), 5 ether);

        stakingContract.withdraw(2 ether);
        assertEq(stakingContract.totalStaked(), 3 ether);
    }

    function testRewardsOverTime() public {
        vm.startPrank(user);
        stakingToken.approve(address(stakingContract), 10 ether);
        stakingContract.stake(5 ether);
        vm.warp(block.timestamp + 7 days);

        uint256 earnedRewards = stakingContract.earned(user);
        assertGt(earnedRewards, 0, "rewards should accumilate over time");
        vm.stopPrank();
    }

    function testUserStake() public {
        vm.startPrank(user);
        stakingToken.approve(address(stakingContract), 10 ether);
        stakingContract.stake(5 ether);
        vm.warp(block.timestamp + 1 days);
        stakingContract.withdraw(3 ether);
        vm.stopPrank();

        uint256 amountStaked = stakingContract.getStakerAmountStaked(address(user));
        uint256 reward = stakingContract.getStakerReward(address(user));
        uint256 userRewardPerToken = stakingContract.getStakeruserRewardPerToken(address(user));

        assertEq(amountStaked, 2 ether);
        assertGt(reward, 0);
        assertGt(userRewardPerToken, 0);
    }

    function testUserGetReward() public {
        vm.startPrank(user);
        stakingToken.approve(address(stakingContract), 10 ether);
        stakingContract.stake(5 ether);
        vm.warp(block.timestamp + 1 hours);
        stakingContract.getReward();
        vm.stopPrank();

        assertGt(rewardsToken.balanceOf(user), 0);
    }
}
