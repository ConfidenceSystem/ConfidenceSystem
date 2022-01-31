//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FidesToken is Ownable, ERC20 {
    constructor() ERC20("FidesToken", "FID") {}

    function mint(address receiver, uint256 amount) public onlyOwner {
        _mint(receiver, amount);
    }

    function burn(address burner, uint256 amount) public onlyOwner {
        _burn(burner, amount);
    }
}
