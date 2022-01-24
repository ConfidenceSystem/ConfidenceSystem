pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface newsubmittedsystems{
    function GetAuditWindow(string memory IPFS) external view returns(uint);
    function GetAuditor(string memory IPFS) external view returns(address);
    function GetPayout(string memory IPFS) external view returns (uint);
    function AuditorPaid(string memory IPFS)external;
    function GetAuditorPaid(string memory IPFS)external view returns (bool);
    function GetOutcome(string memory IPFS) external view returns (uint)
}


interface MockToken_{
        function Transfer(address sender, address receiver, int amount) external;
}

contract PayoutsContract {


    function AuditPayout(string memory IPFS) external {
   
    //get details    
    uint auditwindow=newsubmittedsystems(SubmittedSystemsAddress).GetAuditWindow(IPFS);
    address auditor=newsubmittedsystems(SubmittedSystemsAddress).GetAuditor(IPFS);
    uint  payout = newsubmittedsystems(SubmittedSystemsAddress).GetPayout(IPFS);
   
    //checking stuff
    require(block.timestamp > auditwindow);
    require (newsubmittedsystems(SubmittedSystemsAddress).GetAuditorPaid(IPFS) != true);
    require (newsubmittedsystems(SubmittedSystemsAddress).GetOutcome(IPFS) == 1);
   
    //updating system status
    newsubmittedsystems(SubmittedSystemsAddress).AuditorPaid(IPFS);
   
    //actual transfer
    MockToken_(tokenaddress).Transfer(address(this), auditor, payout);
    }

    function BountyPayout(string memory IPFS, address Hacker, uint Bounty)external{

    }

}



