// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Token.sol";

contract DeployTokens is Script {
    function run() external {
        vm.startBroadcast();
        new StakingToken(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        new RewardToken(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        vm.stopBroadcast();
    }
}
