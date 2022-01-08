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
function MintRep(string memory IPFS, address AuditorAddress) external;
function MintHackerRep(address AuditorAddress, int RepAmount) external;
function BurnRep(string memory IPFS, address AuditorAddress) external;
function ResetStakedRep(string memory IPFS, address AuditorAddress) external;
function GetAlreadyStaked(string memory IPFS, address AuditorAddress) external view returns(int);

}

interface MockToken_ {
    function Transfer(address sender, address receiver, int amount) external;
    function GetBalance(address Account) external view returns(int);
}


contract MockEscrow {


address DeployerAddress;
int payout;
int RepStaked;
bool TimePassed;

 uint[5] fundsfactor;
 uint[5] RepFactor;

    constructor(address deployeraddress) {
        fundsfactor[1]=10;
        fundsfactor[2]=50;
        fundsfactor[3]=100;
        RepFactor[1] = 100;
        RepFactor[2] = 500;
        RepFactor[3] = 1000;
        DeployerAddress=deployeraddress;

    }

address StakerAdress;
address EscrowAddress;
address TokenAddress;
address RealityAddress;
address KlerosProxyAddress;
address SubmitterAddress;

    function SetAddress(address StakerAdress_, address SubmitterAddress_, address TokenAddress_, address RealityAddress_, address KlerosProxyAddress_) public{

require(msg.sender==DeployerAddress);
StakerAdress=StakerAdress_;
EscrowAddress=address(this);
TokenAddress=TokenAddress_;
RealityAddress=RealityAddress_;
KlerosProxyAddress=KlerosProxyAddress_;
SubmitterAddress=SubmitterAddress_;

}

    function PayHacker(string memory IPFS,  uint hackstatusnumeric, address HackerAddress) external{

    int hackerpayout = ((SubmitSystemContract_(SubmitterAddress).GetStakedRep(IPFS)));
    hackerpayout=(int(fundsfactor[hackstatusnumeric])*hackerpayout);
    hackerpayout = hackerpayout/100;

    MockToken_(TokenAddress).Transfer(address(this), HackerAddress, hackerpayout);
    MockStaker_(StakerAdress).MintHackerRep(HackerAddress, int(RepFactor[hackstatusnumeric]));

    }



    function CheckTime(string memory IPFS) public{
        uint TimeEnd = uint(SubmitSystemContract_(SubmitterAddress).GetTimeWindow(IPFS));
        uint currenttime = block.timestamp;
        require (TimeEnd > currenttime);
        TimePassed = true;
    }

    function PayOut(string memory IPFS, address AuditorAddress) public  {
       
         uint TimeEnd = uint(SubmitSystemContract_(SubmitterAddress).GetTimeWindow(IPFS));
         uint currenttime = block.timestamp;
         require (currenttime>TimeEnd, "you fucked it");//&& (SubmitSystemContract_(SubmitterAddress).GetTimeWindowStarted(IPFS)) == true);
         MockStaker_(StakerAdress).BurnRep(IPFS,AuditorAddress);
        payout = ((MockStaker_(StakerAdress).GetStakedRep(IPFS, AuditorAddress)));
       
        int alreadystaked =MockStaker_(StakerAdress).GetAlreadyStaked(IPFS, AuditorAddress);
        payout = payout*(100-alreadystaked);
        payout = payout/100;
        MockStaker_(StakerAdress).MintRep(IPFS, AuditorAddress);
        MockStaker_(StakerAdress).ResetStakedRep(IPFS, AuditorAddress);
        MockToken_(TokenAddress).Transfer(address(this), AuditorAddress, payout);
    }

    function ReturnUnstaked(string memory IPFS) public{
            require (SubmitSystemContract_(SubmitterAddress).GetTimeWindowStarted(IPFS) == true);
            int ReturnedFunds = (SubmitSystemContract_(SubmitterAddress).GetTotalRep(IPFS)) - (SubmitSystemContract_(SubmitterAddress).GetStakedRep(IPFS));
            
            MockToken_(TokenAddress).Transfer(address(this), (SubmitSystemContract_(SubmitterAddress).GetSubmitter(IPFS)), ReturnedFunds);

    }
}