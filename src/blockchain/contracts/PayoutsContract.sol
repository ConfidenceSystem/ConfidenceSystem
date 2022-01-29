pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface newsubmittedsystems{
    function GetAuditWindow(string memory IPFS) external view returns(uint);
    function GetAuditor(string memory IPFS) external view returns(address);
    function GetPayout(string memory IPFS) external view returns (uint);
    function AuditorPaid(string memory IPFS)external;
    function GetAuditorPaid(string memory IPFS)external view returns (bool);
    function GetOutcome(string memory IPFS) external view returns (uint);
}

interface Triage{
function GetPayoutDetails (string memory _IPFS, uint256 _HackID) external view returns (address [10] memory, uint, uint);
}

contract PayoutsContract {

address DeployerAddress;
constructor(address deployeraddress){
DeployerAddress=deployeraddress;
}

address MockStableCoin;
address PayoutsAddress;
address UsersAddress;
address SubmittedSystemsAddress;
address TriageAddress;
address InterfaceAddress;

function SetAddress(address _MockStableCoin, address _PayoutsAddress, address _UsersAddress, address _SubmittedSystemsAddress, address _TriageAddress, address _InterfaceAddress) public{
require(msg.sender==DeployerAddress);
MockStableCoin=_MockStableCoin;
PayoutsAddress=_PayoutsAddress;
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
    //require(block.timestamp > auditwindow);
    require (newsubmittedsystems(SubmittedSystemsAddress).GetAuditorPaid(IPFS) != true);
    require (newsubmittedsystems(SubmittedSystemsAddress).GetOutcome(IPFS) == 1);
   
    //updating system status
    newsubmittedsystems(SubmittedSystemsAddress).AuditorPaid(IPFS);
   
    //actual transfer
    IERC20(MockStableCoin).transferFrom(address(this), auditor,  payout);
    }

    function BountyPayout(string memory IPFS, address Hacker, uint Bounty)external{

    }

    function TriagePayout(string memory _IPFS, uint256 _HackID) external{
        address[10] memory triagers;
        uint payout;
        uint triagercount;
      (triagers, payout, triagercount) = Triage(TriageAddress).GetPayoutDetails(_IPFS, _HackID);

        uint i;
        uint triagerpayout = (payout/triagercount);
        

        for (i=0; i<triagercount; i++){
            IERC20(MockStableCoin).transferFrom(address(this), triagers[i], (triagerpayout));

        }

    }

}



