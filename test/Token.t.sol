// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Token.sol";

contract TokenTest is Test {
    Token public tokenContract;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = makeAddr("user");

        tokenContract = new Token(owner);
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

    function testMinttoSupply() public {
        uint initialSupply = tokenContract.totalSupply();
        assertEq(initialSupply, 100 * 10 ** 18);

        vm.prank(owner);
        tokenContract.mint(user, 10 * 10 ** 18);

        uint newSupply = tokenContract.totalSupply();
        assertEq(newSupply, ((100 * 10 ** 18) + (10 * 10 ** 18)));

        uint userBalance = tokenContract.balanceOf(user);
        assertEq(userBalance, 10 * 10 ** 18);
    }
}
