//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MockToken {


    mapping(address => int) public balance;

    function SetBalance(address Account, int Balance) public{
        balance[Account]=Balance;
    }

    function GetBalance(address Account) external view returns(int){
        return balance[Account];
    }

    function GetBalancePublic(address Account) public view returns(int){
        return balance[Account];
    }

    function Transfer(address sender, address receiver, int amount) external{

        require(balance[sender] >= amount);
        balance[sender]=balance[sender]-amount;
        balance[receiver]=balance[receiver]+amount;

    }




}


