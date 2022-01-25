pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface newsubmittedsystems{
    function GetAuditWindow(string memory IPFS) external view returns(uint);
    function GetAuditor(string memory IPFS) external view returns(address);
    function GetPayout(string memory IPFS) external view returns (uint);
    function AuditorPaid(string memory IPFS)external;
    function GetAuditorPaid(string memory IPFS)external view returns (bool);
    function GetOutcome(string memory IPFS) external view returns (uint);
}

interface Triage{
function GetPayoutDetails (string memory _IPFS, string memory _HackID) external view returns (address [] memory, uint);
}


interface MockToken_{
        function Transfer(address sender, address receiver, int amount) external;
}

contract PayoutsContract {

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
PayoutsAddress=address(this);
UsersAddress= _UsersAddress;
SubmittedSystemsAddress= _SubmittedSystemsAddress;
TriageAddress= _TriageAddress;
InterfaceAddress=_InterfaceAddress;

}



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

    function TriagePayout(string memory _IPFS, string memory _HackID) external{
        address[] triagers;
        uint payout;
        uint triagercount;
        (triagers, payout, triagercount) = Triage(TriageAddress).GetPayoutDetails(_IPFS, _HackID);

        uint i;
        for (i=0; i<triagercount; i++){
            uint triagerpayout = payout/triagercount;
            MockToken_(tokenaddress).Transfer(address(this), triagers[i], triagerpayout);

        }

    }

}



