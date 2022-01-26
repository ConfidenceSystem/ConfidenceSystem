pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface Users{
function GetScore(address auditor) external returns (int);
}

interface mocktoken {
    function Transfer(address sender, address receiver, int amount) external;

}

interface Triage{
    function MakeTriageRequest(string memory _IPFS, uint _HackID, uint _TriagerCount) external;
}

contract SubmittedSystemsContract {

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


function SubmitSystem(string memory IPFS, int MinAuditorScore, uint Payout, address Submitter) public {
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    require (SubmittedSystem_.SetDetails != true);
    SubmittedSystem_.SetDetails=true;
    SubmittedSystem_.Outcome=1;
    mocktoken(TokenAddress).Transfer(Submitter, PayoutsAddress, int(Payout)); // puts money in escrow
    SubmittedSystem_.SubmitterAddress=Submitter;
    SubmittedSystem_.Payout=Payout;
    SubmittedSystem_.MinScore=MinAuditorScore;

}

function SetAuditor(string memory IPFS, address auditor) external {
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];

    require (SubmittedSystem_.Auditor == 0x0000000000000000000000000000000000000000);
    require (Users(UsersAddress).GetScore(auditor) >= SubmittedSystem_.MinScore);

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
        SubmittedSystemHack_.AddressLocalHackCounter[HackSubmitter]++; //local hack counter and ID for each user that submits vulns

        SubmittedSystemHack_.HackCounterAddress[SubmittedSystemHack_.HackCounter]=HackSubmitter; //address of vuln submitter for this ID
        SubmittedSystemHack_.HackCounterAddressID[SubmittedSystemHack_.HackCounter]=SubmittedSystemHack_.AddressLocalHackCounter[HackSubmitter]; //where in user's submitted vulns this vuln is. i.e position 4

        SubmittedSystemHack_.HackHash[HackSubmitter][SubmittedSystemHack_.AddressLocalHackCounter[HackSubmitter]]=HackHash; //submitting hack hash
        return SubmittedSystemHack_.HackCounter; //returning Hack ID
}


function SubmitHackURI(string memory IPFS, string memory HackURI, address HackSubmitter, uint HackID) external {
        SubmittedSystemHack storage SubmittedSystemHack_ = SubmittedSystemHacks[IPFS];
      
        uint LocalHackID = SubmittedSystemHack_.HackCounterAddressID[HackID]; //getting address specific hack position/id
        SubmittedSystemHack_.HackURI[HackSubmitter][LocalHackID]=HackURI; //submitting URI

        Triage(TriageAddress).MakeTriageRequest(IPFS, HackID, 4); //making triage request

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
