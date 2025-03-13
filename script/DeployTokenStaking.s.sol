// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/TokenStaking.sol";

contract DeployTokenStaking is Script {
    function run() external {
        vm.startBroadcast();
        new TokenStaking(
            0x5FbDB2315678afecb367f032d93F642f64180aa3,
            0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
        );
        vm.stopBroadcast();
    }
}
