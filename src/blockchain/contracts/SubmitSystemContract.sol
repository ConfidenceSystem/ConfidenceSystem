//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface MockStaker_ {
    function GetAvailableRep(address AuditorAddress) external view returns(int);
    function UpdateStakedRep(string memory IPFS, address AuditorAddress, int RepStaked) external;
    function GetStakedRep(string memory IPFS, address AuditorAddress) external view returns(int);
}

interface MockEscrow_ {
    function PayOut(string memory IPFS, address SubmitSystemContract, address AuditorContract, address payable AuditorAddress) external;
}

interface MockToken_{
        function Transfer(address sender, address receiver, int amount) external;
        function GetBalance(address Account) external view returns(int);
}

contract SubmitSystemContract {

struct SubmittedSystem{

int StakingTimeWindow;
int TimeWindow;
bool StakingTimeWindowStarted;
bool TimeWindowStarted;
int AuditorRepLevel;
int TotalRep;
int RepStaked;
int Complexity;
int Bounty;
bool Stakeable;
bool SetDetails;
address SubmitterAddress;

}

mapping (string => SubmittedSystem) public SubmittedSystems;

    function SubmitSystem(string memory IPFS, int StakingTimeWindow, int TimeWindow, int AuditorRepLevel, int TotalRep, int Bounty) public { 
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        require(SubmittedSystem_.SetDetails != true);
        SubmittedSystem_.Stakeable=false;

        SubmittedSystem_.StakingTimeWindow=StakingTimeWindow;
        SubmittedSystem_.TimeWindow=TimeWindow;
        SubmittedSystem_.AuditorRepLevel=AuditorRepLevel;
        SubmittedSystem_.TotalRep=TotalRep;
        SubmittedSystem_.Bounty=Bounty;
        SubmittedSystem_.SubmitterAddress=msg.sender;
        SubmittedSystem_.SetDetails=true;
    }

    function FundSystem(string memory IPFS, address payable EscrowAddress, address MockTokenAddress )public{
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        int StakingPayment=SubmittedSystem_.Bounty*SubmittedSystem_.Bounty;
        MockToken_(MockTokenAddress).Transfer(msg.sender, EscrowAddress, StakingPayment);
    }

    function GetSystemDetails(string memory IPFS) public view returns(int, int, int, int, int, int, int, int, bool, bytes memory ){
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        bytes memory address_ =abi.encodePacked(SubmittedSystem_.SubmitterAddress);

        return(int(block.timestamp), SubmittedSystem_.StakingTimeWindow, SubmittedSystem_.TimeWindow, SubmittedSystem_.AuditorRepLevel,SubmittedSystem_.TotalRep, SubmittedSystem_.Complexity, SubmittedSystem_.Bounty, SubmittedSystem_.RepStaked, SubmittedSystem_.Stakeable, address_);
    }

    //should StakeRep happen in Auditors Contract?

    function StakeRep(string memory IPFS, int Rep, address AuditorsContract, address AuditorAddress) public{

        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        int StakerRep = MockStaker_(AuditorsContract).GetAvailableRep(AuditorAddress);
        require (Rep <= SubmittedSystem_.TotalRep && StakerRep >= Rep && SubmittedSystem_.Stakeable == true);
       
        MockStaker_(AuditorsContract).UpdateStakedRep(IPFS, AuditorAddress, Rep);
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