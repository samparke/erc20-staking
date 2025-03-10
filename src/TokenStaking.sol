// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenStaking {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    uint public immutable rewardsPerHour = 1 ether; // 0.01%
    uint public totalStaked;
    mapping(address => uint) public stakedBalance;

    event Staked(address indexed user, uint256 amount);

    constructor(IERC20 _token) {
        token = _token;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "You must stake more than 0");

        token.safeTransferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }
}
