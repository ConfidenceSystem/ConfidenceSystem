pragma solidity ^0.8.0;

import "hardhat/console.sol";
interface newsubmittedsystems{
    function GetAuditWindow(string memory IPFS) external view returns(uint);
    function GetAuditor(string memory IPFS) external view returns(address);
    function GetPayout(string memory IPFS) external view returns (uint);
    function GetOutcome(string memory IPFS) external view returns (uint);
}


contract UsersContract {


struct Auditor {
mapping(uint => string) AuditedContract;
uint ContractCounter;
int Score;
}

mapping (address => Auditor) public Auditors;

function GetScore(address auditor) public returns (int){
    
    Auditor Auditor_ = Auditors[auditor];
    //tallies score every time it is requested (is this too expensive?)
    uint i;
    for (i=0;i<Auditor_.ContractCounter+1;i++){
        uint outcome =  newsubmittedsystems(contractaddress).GetOutcome(Auditor_.AuditedContract[i]);
        uint AuditWindow = newsubmittedsystems(contractaddress).GetAuditWindow(Auditor_.AuditedContract[i]);

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
    Triager Triager_ = Triagers[user];
    if (GetScore(user) > 50 && selection == true && Triager_.IsTriager != true){
   
    Triager_.IsTriager=selection;
    TriageCounter++;
    TriagersList[TriageCounter]=user;
    Triager_.position=TriageCounter;
  
    }
    else if (selection == false && Triager_.IsTriager == true){
    
    Triager_.IsTriager = false;
    TriagersList[Triager_.position]=TriagersList[TriageCounter];
    Triager[TriagersList[TriageCounter]].position=Triager_.position;
    TriageCounter--;
  
    }
}
function GetAvailableTriager(uint position) external returns(address){
require (position <= TriageCounter);
return TriagersList[position];
}



struct Overall{
    int Score;
}



}