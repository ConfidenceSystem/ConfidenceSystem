//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";


interface SubmitSystemContract_{
function GetComplexity(string memory IPFS) external  returns(bytes32);
function GetSeveritiesAggregate(string memory IPFS) external view returns(uint);

}

contract MockStaker {

    
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

    function SetAddress(address EscrowAddress_, address SubmitterAddress_, address TokenAddress_, address RealityAddress_, address KlerosProxyAddress_) public{

require(msg.sender==DeployerAddress);
StakerAdress=address(this);
EscrowAddress=EscrowAddress_;
TokenAddress=TokenAddress_;
RealityAddress=RealityAddress_;
KlerosProxyAddress=KlerosProxyAddress_;
SubmitterAddress=SubmitterAddress_;

}

struct Auditor{

    int AuditorRep;
    int TotalStaked;
    mapping(string => int) StakedRep;
    mapping(string => int) StakedAlready;


}

function SetRep(address AuditorAddress) public{
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    Auditor_.AuditorRep=500;
}

mapping (address => Auditor) public Auditors;

function GetAvailableRep(address AuditorAddress) external view returns(int){

    Auditor storage Auditor_ = Auditors[AuditorAddress];
    int AvailableRep = Auditor_.AuditorRep - Auditor_.TotalStaked;
    return AvailableRep;
}

function AlreadyStaked(string memory IPFS, address AuditorAddress, int StakedAlready) external{
        Auditor storage Auditor_ = Auditors[AuditorAddress];
        Auditor_.StakedAlready[IPFS]=StakedAlready;

}

function GetAlreadyStaked(string memory IPFS, address AuditorAddress) external view returns(int){
Auditor storage Auditor_ = Auditors[AuditorAddress];
     return   Auditor_.StakedAlready[IPFS];
}

function GetStakedRep(string memory IPFS, address AuditorAddress) external view returns(int){
        Auditor storage Auditor_ = Auditors[AuditorAddress];
        return Auditor_.StakedRep[IPFS];

}

function BurnRep(string memory IPFS, address AuditorAddress) external{
    uint hackseverity = SubmitSystemContract_(SubmitterAddress).GetSeveritiesAggregate(IPFS);
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    int RepStaked = Auditor_.StakedRep[IPFS];
    int originalRep=Auditor_.StakedRep[IPFS];
    RepStaked=(RepStaked*(100-int(hackseverity)))/100;
    Auditor_.StakedRep[IPFS]=RepStaked;
    int replost=originalRep-RepStaked;
    Auditor_.AuditorRep = Auditor_.AuditorRep-replost;

}

function UpdateStakedRep(string memory IPFS, address AuditorAddress, int RepStaked) external{

    Auditor storage Auditor_ = Auditors[AuditorAddress];
    Auditor_.StakedRep[IPFS] = Auditor_.StakedRep[IPFS]+RepStaked;
    Auditor_.TotalStaked=Auditor_.TotalStaked+RepStaked;

}

function ResetStakedRep(string memory IPFS, address AuditorAddress) external{
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    Auditor_.TotalStaked=Auditor_.TotalStaked-Auditor_.StakedRep[IPFS];
    Auditor_.StakedRep[IPFS] = 0;


}

function MintRep(string memory IPFS, address AuditorAddress) external{

    uint hackseverity = SubmitSystemContract_(SubmitterAddress).GetSeveritiesAggregate(IPFS);
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    int repgain = ((Auditor_.StakedRep[IPFS]*10)/100);
    //RepGain = uint(SubmitSystemContract_(SubmitterAddress).GetComplexity(IPFS));
   
    repgain = ((repgain*(100-Auditor_.StakedAlready[IPFS]))/100);
    if (hackseverity>10){
        repgain=0;
    }
    Auditor_.AuditorRep= Auditor_.AuditorRep + repgain;

}

function MintHackerRep(address AuditorAddress, int RepAmount) external{
        Auditor storage Auditor_ = Auditors[AuditorAddress];
        Auditor_.AuditorRep= Auditor_.AuditorRep + RepAmount;

}

function GetTotalRep(address AuditorAddress) public view returns(int){
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    return Auditor_.AuditorRep;
}




}
