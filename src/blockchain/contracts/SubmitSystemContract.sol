//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface MockStaker_ {
    function GetAvailableRep(address AuditorAddress) external view returns(int);
    function UpdateStakedRep(string memory IPFS, address AuditorAddress, int RepStaked) external;
    function GetStakedRep(string memory IPFS, address AuditorAddress) external view returns(int);
    function AlreadyStaked(string memory IPFS, address AuditorAddress, int StakedAlready) external;
}

interface MockEscrow_ {
    function PayOut(string memory IPFS,address payable AuditorAddress) external;
    function PayHacker(string memory IPFS, uint hackstatusnumeric, address HackerAddress) external;

}

interface MockToken_{
        function Transfer(address sender, address receiver, int amount) external;
        function GetBalance(address Account) external view returns(int);
}

interface RealityMock_{
   function resultFor(bytes32 question_id) external view returns(bytes32);
  
   function askQuestion  (
   uint256 template_id,
   string memory question,
   address arbitrator,
   uint32 timeout,
   uint32 opening_ts,
   uint256 nonce
) external returns (bytes32 question_id);


}

contract SubmitSystemContract {

address DeployerAddress;

constructor(address deployeraddress){

DeployerAddress=deployeraddress;

}
address StakerAdress;
address EscrowAddress;
address TokenAddress;
address RealityAddress;
address KlerosProxyAddress;
address SubmitterAddress;


function SetAddress(address StakerAdress_, address EscrowAddress_, address TokenAddress_, address RealityAddress_, address KlerosProxyAddress_) public{

require(msg.sender==DeployerAddress);
StakerAdress=StakerAdress_;
EscrowAddress=EscrowAddress_;
TokenAddress=TokenAddress_;
RealityAddress=RealityAddress_;
KlerosProxyAddress=KlerosProxyAddress_;
SubmitterAddress=address(this);

}

struct SubmittedSystem{

bool StakingTimeWindowStarted;
bool TimeWindowStarted;
uint payout;
bool Stakeable;
bool SetDetails;
address SubmitterAddress;

}

struct Hack{

    mapping(address => mapping(int => string)) HackHash;
    mapping (address => mapping (int => string)) HackURI;
    mapping (address => mapping(int => bytes32)) HackVerificationID;
    mapping (address => mapping(int => bytes32)) HackVerificationAnswer;
    mapping (uint => uint) HackSeverities;
    mapping (address => int) Counter;
    uint SeveritiesCounter;
}

struct QuestionHolder{
    bytes32 ComplexityID;
    uint ComplexityAnswer;

    
}


mapping (string => SubmittedSystem) public SubmittedSystems;
mapping(string => Hack) internal Hacks;
mapping (uint => string) AskedQuestions;
uint QuestionsCounter;

mapping(string => QuestionHolder) public Questions;

/*
function RequestComplexity(string memory IPFS) internal returns (string memory) {

    string memory string1= "what is the complexity of this system?\u241f";
    string memory string3='\u241f"1","2","3"\u241feth-technical\u241fen';
    uint i;
    string memory AskingQ= string(abi.encodePacked(string1,IPFS,string3));
 
    for (i=0; i<(QuestionsCounter+1); i++){
        string memory AskedQ= AskedQuestions[i];
        require(keccak256(abi.encodePacked(AskedQ))!=keccak256(abi.encodePacked(AskingQ)));
    }
    QuestionsCounter++;

    uint32 timeout=uint32(block.timestamp+86400);
    uint32 opening_ts=0;
    uint nonce=0;

   Questions[IPFS].ComplexityID = RealityMock_(RealityAddress).askQuestion(2, AskingQ, KlerosProxyAddress, timeout, opening_ts, nonce);
   return AskingQ;
}

/*function ConcatHackString(string memory IPFS, address HackSubmitter) internal view returns(string memory){
    string memory string1= "what is the severity of this hack? if hash does not match explanation DO NOT USE\u241f";
    string memory string3='\u241f"1","2","3"\u241feth-technical\u241fen';
    Hack storage Hack_ = Hacks[IPFS];
    string memory ExplanationURI=Hack_.HackURI[HackSubmitter][Hack_.Counter[HackSubmitter]];
    string memory HackHash=Hack_.HackHash[HackSubmitter][Hack_.Counter[HackSubmitter]];
    return  string(abi.encodePacked(string1,ExplanationURI,HackHash,string3));

}


function RequestHackVerification(address HackSubmitter, string memory IPFS) internal returns (string memory) {


    uint i;
    Hack storage Hack_ = Hacks[IPFS];

    string memory AskingQ= ConcatHackString(IPFS, HackSubmitter);
 
    for (i=0; i<(QuestionsCounter+1); i++){
        string memory AskedQ= AskedQuestions[i];
        require(keccak256(abi.encodePacked(AskedQ))!=keccak256(abi.encodePacked(AskingQ)));
    }
    QuestionsCounter++;

    Hack_.HackVerificationID[HackSubmitter][Hack_.Counter[HackSubmitter]] = RealityMock_(RealityAddress).askQuestion(2, AskingQ, KlerosProxyAddress, uint32(block.timestamp+86400), 0, 0);

   return AskingQ;
}
*/

function GetComplexity(string memory IPFS) external returns(bytes32){
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    SubmittedSystem_.Complexity = RealityMock_(RealityAddress).resultFor(Questions[IPFS].ComplexityID);
    return SubmittedSystem_.Complexity;
}

function GetComplexityNoCall(string memory IPFS) external view returns(bytes32){
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];

    return SubmittedSystem_.Complexity;

}

function GetHack(address HackSubmitter, string memory IPFS) public {
    Hack storage Hack_ = Hacks[IPFS];
    Hack_.HackVerificationAnswer[HackSubmitter][Hack_.Counter[HackSubmitter]] = RealityMock_(RealityAddress).resultFor(Hack_.HackVerificationID[HackSubmitter][Hack_.Counter[HackSubmitter]]);
    bytes32 hackstatus = Hack_.HackVerificationAnswer[HackSubmitter][Hack_.Counter[HackSubmitter]];
    uint hackstatusnumeric = uint(hackstatus);

    if (hackstatusnumeric > 0) {
    MockEscrow_(EscrowAddress).PayHacker(IPFS, hackstatusnumeric, HackSubmitter);
    Hack_.HackSeverities[Hack_.SeveritiesCounter] = hackstatusnumeric;
    Hack_.SeveritiesCounter++;
}
}

    function SubmitSystem(string memory IPFS, int TimeWindow, int MinAuditorScore) public { 
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        require(SubmittedSystem_.SetDetails != true);
        SubmittedSystem_.Stakeable=false;
        SubmittedSystem_.MinAuditorScore=MinAuditorScore;
        SubmittedSystem_.TimeWindow=TimeWindow;
        SubmittedSystem_.SubmitterAddress=msg.sender;
        SubmittedSystem_.SetDetails=true;
        }

    function FundSystem(string memory IPFS )public{
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        int StakingPayment=SubmittedSystem_.TotalRep;
        MockToken_(TokenAddress).Transfer(msg.sender, EscrowAddress, StakingPayment);
    }

   /* function GetSystemDetails(string memory IPFS) public view returns(int, int, int, int, int, int, int, int, bool, bytes memory ){
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        bytes memory address_ =abi.encodePacked(SubmittedSystem_.SubmitterAddress);

        return(int(block.timestamp), SubmittedSystem_.StakingTimeWindow, SubmittedSystem_.TimeWindow, SubmittedSystem_.AuditorRepLevel,SubmittedSystem_.TotalRep, SubmittedSystem_.Complexity, SubmittedSystem_.Bounty, SubmittedSystem_.RepStaked, SubmittedSystem_.Stakeable, address_);
    }*/

    //should StakeRep happen in Auditors Contract?

    function StakeRep(string memory IPFS, int Rep, address AuditorAddress) public{

        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];

        int stakingposition= ((SubmittedSystem_.RepStaked)*100);
        stakingposition=stakingposition/(SubmittedSystem_.TotalRep);
        MockStaker_(StakerAdress).AlreadyStaked(IPFS, AuditorAddress, stakingposition);

        int StakerRep = MockStaker_(StakerAdress).GetAvailableRep(AuditorAddress);
        require (Rep <= SubmittedSystem_.TotalRep && StakerRep >= Rep && SubmittedSystem_.Stakeable == true);
       
        MockStaker_(StakerAdress).UpdateStakedRep(IPFS, AuditorAddress, Rep);
        SubmittedSystem_.RepStaked=SubmittedSystem_.RepStaked+Rep;
        
        if (SubmittedSystem_.RepStaked==SubmittedSystem_.TotalRep){
            SubmittedSystem_.Stakeable=false;
        }

    }

    function StartStakingWindow(string memory IPFS) public returns (int) {

        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        require(SubmittedSystem_.StakingTimeWindowStarted != true);
        SubmittedSystem_.StakingTimeWindowStarted=true;
        int WindowLength = SubmittedSystem_.StakingTimeWindow;
        SubmittedSystem_.StakingTimeWindow=int(block.timestamp)+WindowLength;
        SubmittedSystem_.Stakeable=true;
        return SubmittedSystem_.StakingTimeWindow;


    }

    function StartTimeWindow(string memory IPFS) public {
        
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        require(SubmittedSystem_.TimeWindowStarted != true);
        require(int(block.timestamp)>SubmittedSystem_.StakingTimeWindow);
        SubmittedSystem_.TimeWindowStarted=true;
        SubmittedSystem_.Stakeable=false;
        int WindowLength = SubmittedSystem_.TimeWindow;
        SubmittedSystem_.TimeWindow=int(block.timestamp)+WindowLength;
    }

    function SubmitHackHash (string memory IPFS, string memory HackHash) public {
        Hack storage Hack_ = Hacks[IPFS];
        Hack_.HackHash[msg.sender][Hack_.Counter[msg.sender]] = HackHash;
        Hack_.Counter[msg.sender]++;


    }


    function SubmitHack(string memory IPFS, string memory ExplanationURI) public {
        Hack storage Hack_ = Hacks[IPFS];
        Hack_.HackURI[msg.sender][Hack_.Counter[msg.sender]] = ExplanationURI;
        RequestHackVerification(msg.sender, IPFS); 


    }

    function GetHash(string memory IPFS, int Counter) public view returns (string memory){
        Hack storage Hack_ = Hacks[IPFS];
        string memory hackhash = Hack_.HackHash[msg.sender][Counter];
        return hackhash;

    }

    function GetSeveritiesAggregate(string memory IPFS) external view returns(uint){
        Hack storage Hack_ = Hacks[IPFS];
        uint i;
        uint SeveritiesAggregate;
        for (i=0; i<Hack_.SeveritiesCounter+1; i++){
           if (Hack_.HackSeverities[i] == 1){
               SeveritiesAggregate=SeveritiesAggregate+(10);
           }
           else if(Hack_.HackSeverities[i] == 2){
            SeveritiesAggregate=SeveritiesAggregate+(50);
           }
           else if(Hack_.HackSeverities[i]==3){
            SeveritiesAggregate=SeveritiesAggregate+(100);
           }
        }
    if (SeveritiesAggregate > 100){
        SeveritiesAggregate=100;
    }
    return SeveritiesAggregate;
    }

    function GetExplanation(string memory IPFS, int Counter) public view returns (string memory){
        Hack storage Hack_ = Hacks[IPFS];
        string memory hackURI = Hack_.HackURI[msg.sender][Counter];
        return hackURI;

    }


    function GetTimeWindow(string memory IPFS) external view returns(int){
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        return SubmittedSystem_.TimeWindow;
    }

    function GetTimeWindowStarted(string memory IPFS)external view returns(bool){
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        return SubmittedSystem_.TimeWindowStarted;

    }

    function GetStakedRep(string memory IPFS) external view returns(int) {
    SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
    return SubmittedSystem_.RepStaked;
    }

    function GetTotalRep(string memory IPFS) external view returns(int){
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        return SubmittedSystem_.TotalRep;

    }

    function GetSubmitter(string memory IPFS) external view returns(address){
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        return SubmittedSystem_.SubmitterAddress;

    }





}