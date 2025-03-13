// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingToken is ERC20, Ownable {
    constructor(address initialOwner) ERC20("StakingToken", "STN") Ownable(initialOwner) {
        _mint(msg.sender, 100 ether);
    }
}

contract RewardToken is ERC20, Ownable {
    constructor(address initialOwner) ERC20("RewardToken", "RTN") Ownable(initialOwner) {
        _mint(msg.sender, 100 ether);
    }
}
