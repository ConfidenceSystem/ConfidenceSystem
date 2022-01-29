pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract FidesToken is ERC20 {
   
    constructor() public ERC20("FidesToken", "FID") {
        
    }

    function MintMore(address receiver, uint amount) external {
        _mint(receiver, amount);

    }

    function Burn(address burner, uint amount) external {
        _burn(burner, amount);
    }


}

