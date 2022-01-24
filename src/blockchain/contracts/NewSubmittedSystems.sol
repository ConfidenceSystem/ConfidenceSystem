pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface UsersContract{
function GetScore(address auditor) external returns (int);
}

contract SubmittedSystemsContract {

struct SubmittedSystem{

    uint AuditWindowEnd;
    uint Payout;
    bool AuditorPaid;
    uint Outcome; //numbers correspond to outcome details (0=still under audit) (1=no vulns found) (2-6 = vulns found(higher = more severe))
    address Auditor;
    int MinScore;
    bool SetDetails;
    address SubmitterAddress;
}

struct SubmittedSystemHack {
    mapping (address => mapping(uint => string)) HackHash;
    mapping (address => mapping(uint => string)) HackURI;
    mapping (address => mapping(uint => uint)) HackOutcome; //0-5, gauging severity, 0 being spam, 5 being crit vuln
    mapping (address => uint) AddressLocalHackCounter;
    mapping (uint => address) HackCounterAddress;
    mapping (uint => uint) HackCounterAddressID;
    uint HackCounter;
}

mapping (string => SubmittedSystem) public SubmittedSystems;
mapping (string => SubmittedSystemHack) public SubmittedSystemHacks;


function SubmitSystem(string memory IPFS, int MinAuditorScore, uint Payout) external {
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    require (SubmittedSystem_.SetDetails != true);
    SubmittedSystem_.SetDetails=true;
    SubmittedSystem_.Payout=Payout;
    SubmittedSystem_.MinScore=MinAuditorScore;

}

function SetAuditor(string memory IPFS, address auditor) external {
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];

    require (SubmittedSystem_.Auditor == 0x0000000000000000000000000000000000000000);
    require (UsersContract(UsersContractAddress).GetScore(auditor) > SubmittedSystem_.MinScore);

    SubmittedSystem_.Auditor=auditor;
    SubmittedSystem_.AuditWindowEnd=block.timestamp+100; //figure out how long 2 weeks is in eth time
}

function AuditorPaid(string memory IPFS)external{
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    SubmittedSystem_.AuditorPaid=true;
}

function SubmitHackHash(string memory IPFS, string memory HackHash, address HackSubmitter)external returns (uint){
        SubmittedSystemHack storage SubmittedSystemHack_ = SubmittedSystemHacks[IPFS]; 
        
        SubmittedSystemHack_.HackCounter++; //overall hack counter and ID for system
        SubmittedSystemHack_[HackSubmitter].AddressLocalHackCounter++; //local hack counter and ID for each user that submits vulns

        SubmittedSystemHack_.HackCounterAddress[SubmittedSystemHack_.HackCounter]=HackSubmitter; //address of vuln submitter for this ID
        SubmittedSystemHack_.HackCounterAddressID[SubmittedSystemHack_.HackCounter]=SubmittedSystemHack_[HackSubmitter].AddressLocalHackCounter; //where in user's submitted vulns this vuln is. i.e position 4

        SubmittedSystemHack_.HackHash[HackSubmitter][SubmittedSystemHack_[HackSubmitter].AddressLocalHackCounter]=HackHash; //submitting hack hash
        return SubmittedSystemHack_.HackCounter; //returning Hack ID
}


function SubmitHackURI(string memory IPFS, string memory HackURI, address HackSubmitter, uint HackID) external {
        SubmittedSystemHack storage SubmittedSystemHack_ = SubmittedSystemHacks[IPFS];
      
        uint LocalHackID = SubmittedSystemHack_.HackCounterAddressID[HackID]; //getting address specific hack position/id
        SubmittedSystemHack_.HackURI[HackSubmitter][LocalHackID]=HackURI; //submitting URI

        //request triage
}   

//Getters, all restricted to view.

function GetOutcome(string memory IPFS) external view returns (uint){
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    return SubmittedSystem_.Outcome;
}

function GetAuditorPaid(string memory IPFS)external view returns (bool){
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    return SubmittedSystem_.AuditorPaid;
}

function GetPayout(string memory IPFS) external view returns (uint){
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    return SubmittedSystem_.Payout;
}
function GetAuditor(string memory IPFS) external view returns(address){
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    return SubmittedSystem_.Auditor;
}

function GetAuditWindow(string memory IPFS) external view returns(uint){
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    return SubmittedSystem_.AuditWindowEnd;
}

}
