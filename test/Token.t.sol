// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Token.sol";

contract TokenTest is Test {
    Token public tokenContract;

    function setUp() public {
        tokenContract = new Token();
    }

    function testTokenName() public view {
        string memory name = tokenContract.name();
        assertEq(name, "Token");
    }

    function testTokenSymbol() public view {
        string memory symbol = tokenContract.symbol();
        assertEq(symbol, "TKN");
    }

    function testInitialSupply() public view {
        uint supply = tokenContract.totalSupply();
        assertEq(supply, 100 * 10 ** 18);
    }
}
