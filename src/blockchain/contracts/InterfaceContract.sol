//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface SubmittedSystems {
function SubmitSystem(string memory IPFS, int MinAuditorScore, uint Payout) external;
function SetAuditor(string memory IPFS, address auditor) external;
function SubmitHackHash(string memory IPFS, string memory HackHash, address HackSubmitter)external returns (uint);
function SubmitHackURI(string memory IPFS, string memory HackURI, address HackSubmitter, uint HackID) external;
}
interface Triage {
    function CommitVoteHash(string memory _IPFS, uint _HackID, bytes32 _VoteHash, address _Triager) external;
    function RevealVote(string memory _IPFS, uint _HackID, uint256 _Vote, uint _Nonce, address _Triager) external;
}
interface Payouts{
    function AuditPayout(string memory IPFS) external;
    function TriagePayout(string memory _IPFS, uint _HackID) external;
}

contract InterfaceContract {

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
InterfaceAddress=address(this);

}



    function SubmitSystem(string memory IPFS, int MinAuditorScore, uint FundsAmount) public {
        SubmittedSystems(SubmittedSystemsAddress).SubmitSystem(IPFS, MinAuditorScore, FundsAmount);
    }

    function Audit(string memory IPFS) public{
        SubmittedSystems(SubmittedSystemsAddress).SetAuditor(IPFS, msg.sender);
    }

    function SubmitHackHash(string memory IPFS, string memory HackData)public returns(uint){
        uint HackID;
        HackID= SubmittedSystems(SubmittedSystemsAddress).SubmitHackHash(IPFS, HackData, msg.sender);
        return HackID; // User must remember this or have stored locally.
    }
    function SubmitHackURI(string memory IPFS, string memory HackURI, uint HackID) public {
        SubmittedSystems(SubmittedSystemsAddress).SubmitHackURI(IPFS, HackURI, msg.sender, HackID);
    }

    function TriageVoteHash(string memory _IPFS, uint _HackID, bytes32 _VoteHash) public{
        Triage(TriageAddress).CommitVoteHash(_IPFS, _HackID, _VoteHash, msg.sender);
    }
    function RevealTriageVote(string memory _IPFS, uint _HackID, uint _Vote, uint _Nonce) public {
        Triage(TriageAddress).RevealVote(_IPFS, _HackID, _Vote, _Nonce, msg.sender);
    }

    function RequestAuditPayout(string memory IPFS)public{
        Payouts(PayoutsAddress).AuditPayout(IPFS);
    }

    function RequestTriagePayout(string memory _IPFS, uint _HackID)public{
        Payouts(PayoutsAddress).TriagePayout(_IPFS, _HackID);
    }

    function RequestBountyPayout()public{}




}