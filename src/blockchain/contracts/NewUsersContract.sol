pragma solidity ^0.8.0;

import "hardhat/console.sol";
interface SubmittedSystems{
    function GetAuditWindow(string memory IPFS) external view returns(uint);
    function GetAuditor(string memory IPFS) external view returns(address);
    function GetPayout(string memory IPFS) external view returns (uint);
    function GetOutcome(string memory IPFS) external view returns (uint);
}


contract NewUsersContract {

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



struct Auditor {
mapping(uint => string) AuditedContract;
uint ContractCounter;
int Score;
}

mapping (address => Auditor) public Auditors;

function GetScore(address auditor) public returns (int){
    
    Auditor storage Auditor_ = Auditors[auditor];
    //tallies score every time it is requested (is this too expensive?)
    uint i;
    for (i=0;i<Auditor_.ContractCounter+1;i++){
        int outcome =  int(SubmittedSystems(SubmittedSystemsAddress).GetOutcome(Auditor_.AuditedContract[i]));
        uint AuditWindow = SubmittedSystems(SubmittedSystemsAddress).GetAuditWindow(Auditor_.AuditedContract[i]);

        if ((outcome == 0 || outcome == 1)&&(block.timestamp > AuditWindow)){
            outcome = int(outcome);
            Auditor_.Score=Auditor_.Score+outcome;
        }
        else if (outcome > 1 && block.timestamp > AuditWindow){
            outcome = int(outcome);
            Auditor_.Score=Auditor_.Score - (outcome*10);
        }
        else{}
    }
    return Auditor_.Score;
}

 

struct Hacker{
    mapping (uint => string) IPFS;
    uint Counter;
    int Score;
}

struct Triager{
    bool IsTriager;
    int Score;
    uint position;
}

mapping (address => Triager) public Triagers;
mapping (uint => address) public TriagersList;
uint TriageCounter;


function UpdateAvailableTriagers(address user, bool selection) external {
    Triager storage Triager_ = Triagers[user];

    // Adding a triager
    if (GetScore(user) > 50 && selection == true && Triager_.IsTriager != true){
   
    Triager_.IsTriager=selection;
    TriageCounter++;
    TriagersList[TriageCounter]=user;
    Triager_.position=TriageCounter;
  
    }

    // Removing a triager
    else if (selection == false && Triager_.IsTriager == true){
    
    Triager_.IsTriager = false;
    TriagersList[Triager_.position]=TriagersList[TriageCounter];
    Triager storage Triager1_ = Triagers[TriagersList[TriageCounter]];
    Triager1_.position  = Triager_.position;
    TriageCounter--;
  
    }
}
function GetAvailableTriager(uint position) external view returns(address){
require (position <= TriageCounter);
return TriagersList[position];
}

function GetTriageCounter()external view returns(uint){
    return TriageCounter;
}



struct Overall{
    int Score;
}



}