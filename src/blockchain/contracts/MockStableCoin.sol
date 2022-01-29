pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockStableCoin is Ownable, ERC20 {
   
    constructor() public ERC20("MockStableCoin", "STABLE") {
        
    }
    
    function Mint(address receiver, uint amount) public onlyOwner  {
        _mint(receiver, amount);

    }

}