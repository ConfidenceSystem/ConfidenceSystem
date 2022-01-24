//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract NewInterface {


    function SubmitSystem(string memory IPFS, int MinAuditorScore, uint FundsAmount) public {}

    function Audit(string memory IPFS) public{}

    function SubmitHack(string memory IPFS, string memory HackData, uint HackorHash)public{}

    function TriageVote(uint TriageRequestID)public{}
    
    function RequestPayout(string memory IPFS)public{}




}