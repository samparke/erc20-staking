// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Token.sol";

contract TokenDeploy is Script {
    function run() external {
        vm.startBroadcast();
        new Token();
        vm.stopBroadcast();
    }
}
