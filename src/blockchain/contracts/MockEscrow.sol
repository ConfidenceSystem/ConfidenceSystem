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
}

interface MockToken_ {
    function Transfer(address sender, address receiver, int amount) external;
    function GetBalance(address Account) external view returns(int);
}


contract MockEscrow {

    function PayOut(string memory IPFS, address SubmitSystemContract, address AuditorContract, address AuditorAddress, address MockTokenAddress) public{
        require(int(block.timestamp)>(SubmitSystemContract_(SubmitSystemContract).GetTimeWindow(IPFS)) && (SubmitSystemContract_(SubmitSystemContract).GetTimeWindowStarted(IPFS)) == true);
        int payout = (SubmitSystemContract_(SubmitSystemContract).GetBounty(IPFS))*(MockStaker_(AuditorContract).GetStakedRep(IPFS, AuditorAddress));
        int RepStaked = MockStaker_(AuditorContract).GetStakedRep(IPFS, AuditorAddress);
        RepStaked = RepStaked -(2*(RepStaked));
        MockStaker_(AuditorContract).MintRep(IPFS, AuditorAddress);
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