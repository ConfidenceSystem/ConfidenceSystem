//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract insurance{


    struct SubmittedSystem{
        uint TotalCoverage;
        uint Risk;
        mapping(uint => address) RiskAssesors;
        address Submitter;
    }

    
    //request risk assesment

    //get risk

    //desired coverage amount * risk + payment intervals

    //function to request insurance payout if hack happens

    //penalize risk assesors if contract is hacked before a certain period of time

    

}