//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MockToken {


address DeployerAddress;
constructor(address deployeraddress){
DeployerAddress=deployeraddress;
}

address TokenAddress;
address PayoutsAddress;
address UsersAddress;
address SubmittedSystemsAddress;
address TriageAddress;
address InterfaceAddress;

function SetAddress(address _TokenAddress, address _PayoutsAddress, address _UsersAddress, address _SubmittedSystemsAddress, address _TriageAddress, address _InterfaceAddress) public{
require(msg.sender==DeployerAddress);
TokenAddress=_TokenAddress;
PayoutsAddress=_PayoutsAddress;
UsersAddress= _UsersAddress;
SubmittedSystemsAddress= _SubmittedSystemsAddress;
TriageAddress= _TriageAddress;
InterfaceAddress=_InterfaceAddress;

}


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


