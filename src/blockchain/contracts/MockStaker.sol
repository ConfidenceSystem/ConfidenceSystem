//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";


interface SubmitSystemContract_{
function GetComplexity(string memory IPFS, address RealityMockAddress) external  returns(bytes32);
function GetSeveritiesAggregate(string memory IPFS) external view returns(uint);

}

contract MockStaker {

struct Auditor{

    int AuditorRep;
    int TotalStaked;
    mapping(string => int) StakedRep;

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

function GetStakedRep(string memory IPFS, address AuditorAddress) external view returns(int){
        Auditor storage Auditor_ = Auditors[AuditorAddress];
        return Auditor_.StakedRep[IPFS];

}

function BurnRep(string memory IPFS, address AuditorAddress, address SubmitSystemContract) external{
    uint hackseverity = SubmitSystemContract_(SubmitSystemContract).GetSeveritiesAggregate(IPFS);
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    int RepStaked = Auditor_.StakedRep[IPFS];
    int originalRep=Auditor_.StakedRep[IPFS];
    RepStaked=(RepStaked*(100-int(hackseverity)))/100;
    Auditor_.StakedRep[IPFS]=RepStaked;
    int replost=originalRep=RepStaked;
    Auditor_.AuditorRep = Auditor_.AuditorRep-replost;

}

function UpdateStakedRep(string memory IPFS, address AuditorAddress, int RepStaked) external{

    Auditor storage Auditor_ = Auditors[AuditorAddress];
    Auditor_.StakedRep[IPFS] = Auditor_.StakedRep[IPFS]+RepStaked;
    Auditor_.TotalStaked=Auditor_.TotalStaked+RepStaked;

}

function MintRep(string memory IPFS, address AuditorAddress, address SubmitSystemContract, address RealityMock) external{

    uint hackseverity = SubmitSystemContract_(SubmitSystemContract).GetSeveritiesAggregate(IPFS);
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    uint RepGain;
    RepGain = uint(SubmitSystemContract_(SubmitSystemContract).GetComplexity(IPFS,RealityMock));
    int repgain= int(RepGain*100);
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
