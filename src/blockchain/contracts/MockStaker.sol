//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

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

function UpdateStakedRep(string memory IPFS, address AuditorAddress, int RepStaked) external{
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    Auditor_.StakedRep[IPFS] = Auditor_.StakedRep[IPFS]+RepStaked;
    Auditor_.TotalStaked=Auditor_.TotalStaked+RepStaked;

}

function MintRep(string memory IPFS, address AuditorAddress) external{
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    int RepGain = Auditor_.StakedRep[IPFS];
    RepGain =  (((RepGain)/10)*2);
    Auditor_.AuditorRep= Auditor_.AuditorRep + RepGain;

}

function GetTotalRep(address AuditorAddress) public view returns(int){
    Auditor storage Auditor_ = Auditors[AuditorAddress];
    return Auditor_.AuditorRep;
}




}

