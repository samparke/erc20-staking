// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenStaking {
    using SafeERC20 for IERC20;

    address public owner;

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    // the amount of time the rewards last for
    // in a real world scenario, there would either be a fixed pool supply or time where tokens are distributed
    uint256 public duration;

    // in our case, we have an end time. this is the timestamp of when rewards finish
    uint256 public finishAt;

    // reward to be provided per second
    uint256 public rewardRate;

    // total staked in the ocntract
    uint256 public totalStaked;

    // minimum of last updated time and reward finish time
    uint256 public updatedAt;

    // the current reward per token stored. Important as this value fluctates with time and number of users providing liquidity
    // the sum of (reward rate * dt * 1e18 / total supply)
    uint256 public rewardPerTokenStored;

    // staking details
    struct Staker {
        // amount the user has staked
        uint256 amountStaked;
        // (the rewardPerToken value at the point of staking/unstaking etc)
        // this ensures user receives fair rewards
        // e.g. if they begin staking at 0.5 ether reward per token, they will receive rewards from that point onwards...
        // unlike users who provided liquidity when it was 0.1 rewardPerToken
        uint256 userRewardPerToken;
        // the last time they staked, this is used to calculate the time elapsed to calculate rewards
        uint256 lastTimeStaked;
        // reward to be claimed
        uint256 reward;
    }

    // the mapping of users to their staked details
    mapping(address => Staker) public stakers;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "must be owner");
        _;
    }

    modifier updateReward(address _account) {
        // calculates and stores current rewardPerToken
        rewardPerTokenStored = rewardsPerToken();
        // aims to get current timestamp
        // if reward period is ongoing, updatedAt will be the current block.timestamp
        updatedAt = lastTimeRewardApplicable();

        // checks if _account is a valid address
        // account(0) is a global invalid address: (0x000000...)
        if (_account != address(0)) {
            stakers[_account].reward = earned(_account);
            stakers[_account].userRewardPerToken = rewardPerTokenStored;
        }
        _;
    }

    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        // aims to get the minimum between the finish time and current time
        // if reward period is ongoing, the minimum will be the block.timestamp
        return _min(finishAt, block.timestamp);
    }

    // if y is greater or equal to x, return x, if not y
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    function rewardsPerToken() public view returns (uint256) {
        // if total staked = 0 (no liquidity providers, the rewardPerToken = 0)
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }

        return rewardPerTokenStored + (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) / totalStaked;
    }

    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "You must stake more than 0");

        stakers[msg.sender].amountStaked += amount;
        stakers[msg.sender].lastTimeStaked = block.timestamp;
        totalStaked += amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "You must unstake more than 0");
        require(stakers[msg.sender].amountStaked >= amount);

        stakers[msg.sender].amountStaked -= amount;
        totalStaked -= amount;
        stakingToken.safeTransfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function earned(address _account) public view returns (uint256) {
        return ((stakers[_account].amountStaked * (rewardsPerToken() - stakers[_account].userRewardPerToken)) / 1e18)
            + stakers[_account].reward;
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = stakers[msg.sender].reward;
        if (reward > 0) {
            stakers[msg.sender].reward = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    function setRewardDuration(uint256 _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint256 _amount) external onlyOwner updateReward(address(0)) {
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint256 remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(rewardRate * duration <= rewardsToken.balanceOf(address(this)), "reward amount > balance");

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function getStakerAmountStaked(address _account) public view returns (uint256) {
        return stakers[_account].amountStaked;
    }

    function getStakerLastTimeStaked(address _account) public view returns (uint256) {
        return stakers[_account].lastTimeStaked;
    }

    function getStakerReward(address _account) public view returns (uint256) {
        return stakers[_account].reward;
    }

    function getStakeruserRewardPerToken(address _account) public view returns (uint256) {
        return stakers[_account].userRewardPerToken;
    }
}
