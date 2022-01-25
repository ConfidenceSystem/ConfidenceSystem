//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract NewInterface {

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
InterfaceAddress=address(this);

}



    function SubmitSystem(string memory IPFS, int MinAuditorScore, uint FundsAmount) public {}

    function Audit(string memory IPFS) public{}

    function SubmitHack(string memory IPFS, string memory HackData, uint HackorHash)public{}

    function TriageVote(uint TriageRequestID)public{}
    
    function RequestPayout(string memory IPFS)public{}




}