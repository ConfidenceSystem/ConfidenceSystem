//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "hardhat/console.sol";


interface SubmitSystemContract_{
function GetBounty(string memory IPFS)external view returns(int);
function GetTimeWindowStarted(string memory IPFS)external view returns(bool);
function GetTimeWindow(string memory IPFS) external view returns(int);
function GetTotalRep(string memory IPFS) external view returns(int);
function GetStakedRep(string memory IPFS) external view returns(int);
function GetSubmitter(string memory IPFS) external view returns(address);
}

interface MockStaker_ {
function GetStakedRep(string memory IPFS, address AuditorAddress) external view returns(int);
function UpdateStakedRep(string memory IPFS, address AuditorAddress, int RepStaked) external;
function MintRep(string memory IPFS, address AuditorAddress, address SubmitSystemContract, address RealityMockAddress) external;
function MintHackerRep(address AuditorAddress, int RepAmount) external;
function BurnRep(string memory IPFS, address AuditorAddress, address SubmitSystemContract) external;
}

interface MockToken_ {
    function Transfer(address sender, address receiver, int amount) external;
    function GetBalance(address Account) external view returns(int);
}


contract MockEscrow {


int payout;
int RepStaked;
bool TimePassed;

 uint[5] fundsfactor;
 uint[5] RepFactor;

    constructor() {
        fundsfactor[1]=10;
        fundsfactor[2]=50;
        fundsfactor[3]=100;
        RepFactor[1] = 100;
        RepFactor[2] = 500;
        RepFactor[3] = 1000;
    }

    function PayHacker(string memory IPFS, address SubmitSystemContract, uint hackstatusnumeric, address HackerAddress, address MockTokenAddress, address MockStakerAddress ) external{

    int hackerpayout = ((SubmitSystemContract_(SubmitSystemContract).GetBounty(IPFS))*(SubmitSystemContract_(SubmitSystemContract).GetStakedRep(IPFS)));
    hackerpayout=(int(fundsfactor[hackstatusnumeric])*hackerpayout);
    hackerpayout = hackerpayout/100;

    MockToken_(MockTokenAddress).Transfer(address(this), HackerAddress, hackerpayout);
    MockStaker_(MockStakerAddress).MintHackerRep(HackerAddress, int(RepFactor[hackstatusnumeric]));

    }



    function CheckTime(string memory IPFS, address SubmitSystemContract) public{
        uint TimeEnd = uint(SubmitSystemContract_(SubmitSystemContract).GetTimeWindow(IPFS));
        uint currenttime = block.timestamp;
        require (TimeEnd > currenttime);
        TimePassed = true;
    }

    function PayOut(string memory IPFS, address SubmitSystemContract, address AuditorContract, address AuditorAddress, address MockTokenAddress, address RealityMockAddress) public  {
       
         uint TimeEnd = uint(SubmitSystemContract_(SubmitSystemContract).GetTimeWindow(IPFS));
         uint currenttime = block.timestamp;
         require (currenttime>TimeEnd, "you fucked it");//&& (SubmitSystemContract_(SubmitSystemContract).GetTimeWindowStarted(IPFS)) == true);
         MockStaker_(AuditorContract).BurnRep(IPFS,AuditorAddress,SubmitSystemContract);
        payout = ((SubmitSystemContract_(SubmitSystemContract).GetBounty(IPFS))*(MockStaker_(AuditorContract).GetStakedRep(IPFS, AuditorAddress)));
        RepStaked = MockStaker_(AuditorContract).GetStakedRep(IPFS, AuditorAddress);
        RepStaked = (RepStaked -(2*(RepStaked)));

         MockStaker_(AuditorContract).MintRep(IPFS, AuditorAddress, SubmitSystemContract, RealityMockAddress);
        MockStaker_(AuditorContract).UpdateStakedRep(IPFS, AuditorAddress, RepStaked);
          MockToken_(MockTokenAddress).Transfer(address(this), AuditorAddress, payout);
    }

    function ReturnUnstaked(string memory IPFS, address SubmitSystemContract, address MockTokenAddress) public{
            require (SubmitSystemContract_(SubmitSystemContract).GetTimeWindowStarted(IPFS) == true);
            int ReturnedFunds = (SubmitSystemContract_(SubmitSystemContract).GetTotalRep(IPFS)) - (SubmitSystemContract_(SubmitSystemContract).GetStakedRep(IPFS));
            ReturnedFunds = ReturnedFunds * (SubmitSystemContract_(SubmitSystemContract).GetBounty(IPFS));
            MockToken_(MockTokenAddress).Transfer(address(this), (SubmitSystemContract_(SubmitSystemContract).GetSubmitter(IPFS)), ReturnedFunds);

    }
}