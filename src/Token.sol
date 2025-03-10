// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    constructor(
        address initialOwner
    ) ERC20("Token", "TKN") Ownable(initialOwner) {
        _mint(msg.sender, 100 ether);
    }

    function mint(address _recipient, uint256 _amount) public {
        _mint(_recipient, _amount);
    }
}
