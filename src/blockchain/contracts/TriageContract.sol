pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface NewUsers {
function GetAvailableTriager(uint256 _position) external returns(address);
function GetTriageCounter()external returns(uint256);
}

interface Payouts {
    function TriagePayout(string memory _IPFS, uint256 _HackID) external;

}

interface SubmittedSystem {
   function SetOutcome(string memory _IPFS, uint256 outcome) external;
}

contract TriageContract {


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
InterfaceAddress=_InterfaceAddress;

}

    struct TriageRequest {
        string IPFS;
        uint256 HackID;
        uint256 TriageWindowEnd;
        uint256 TriagerCount;
        mapping (uint256 => address) Triagers;
        mapping (address => bytes32) VoteHash;
        mapping (address => uint256) Vote; 
        uint256 Outcome;
        uint256 TriagePayout;
    }

    mapping (string => TriageRequest) public TriageRequests;

    function MakeTriageRequest(string memory _IPFS, uint256 _HackID, uint256 _TriagerCount) public {

        //setting request details
        string memory ID = string (abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        TriageRequest_.IPFS = _IPFS;
        TriageRequest_.HackID = _HackID;
        TriageRequest_.TriagerCount = _TriagerCount;
        TriageRequest_.TriagePayout=100; // we can change this later
        TriageRequest_.TriageWindowEnd = block.timestamp+100; // starts triage window, will figure out equivalent of 3 days in unix time
        TriageRequest_.Outcome=9; //0 is in use as a valid outcome, so this just signifies that consensus hasn't been found yet
        //getting triagers
        uint256 randomness = uint256(blockhash(block.number)); // will do chainlink mocks later
        uint256 i;
        uint256 TriageCounter = NewUsers(UsersAddress).GetTriageCounter();
        for (i = 0; i < TriageRequest_.TriagerCount; i++) {
        TriageRequest_.Triagers[i] = NewUsers(UsersAddress).GetAvailableTriager(uint256(keccak256(abi.encode(randomness, i))) % TriageCounter); // Getting random triagers
        }

    }

    function CommitVoteHash(string memory _IPFS, uint256 _HackID, bytes32 _VoteHash, address _Triager) external returns(bytes32) {
        string memory ID = string (abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        uint256 i;
        for (i=0; i<TriageRequest_.TriagerCount; i++){ 
            if (TriageRequest_.Triagers[i]==_Triager){ //checking triager is eligible
                TriageRequest_.VoteHash[_Triager]=_VoteHash;


            }
        }
        return TriageRequest_.VoteHash[_Triager];
    }

    function RevealVote(string memory _IPFS, uint256 _HackID, uint256 _Vote, uint256 _Nonce, address _Triager) external {
        string memory ID = string (abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        bytes32 VoteHash = keccak256(abi.encodePacked(_Vote, _Nonce, _IPFS, _HackID)); 
        require (VoteHash == TriageRequest_.VoteHash[_Triager], 'hashes dont match'); //Checking Hash
     if (VoteHash == TriageRequest_.VoteHash[_Triager]){
        TriageRequest_.Vote[_Triager]=_Vote;
     }
        //store used nonces and spot check
        //if you can get a Triager's vote before reveal, they are penalized and you are rewarded.
    }

    function GetVoteOutcome(string memory _IPFS, uint256 _HackID) public {
        string memory ID = string (abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];

        //require(block.timestamp > TriageRequest_.TriageWindowEnd);
        uint256 i;
        uint256[10] memory tally;
        for (i=0; i< TriageRequest_.TriagerCount; i++){
            address triager = TriageRequest_.Triagers[i];
            tally[TriageRequest_.Vote[triager]]++; //get triagers vote, and tallies that position in array
            if (tally[TriageRequest_.Vote[triager]] == (TriageRequest_.TriagerCount)){ //if the amount of votes on certain severity == amount of triagers, sets outcome to that severity
                TriageRequest_.Outcome=TriageRequest_.Vote[triager];
            }

        }
        if (TriageRequest_.Outcome == 9){
            MakeTriageRequest(_IPFS, _HackID, TriageRequest_.TriagerCount);
            //if consensus is not met, overwrites and gets new triagers
        }

        if (TriageRequest_.Outcome != 9){
            SubmittedSystem(SubmittedSystemsAddress).SetOutcome(_IPFS, TriageRequest_.Outcome);
            Payouts(PayoutsAddress).TriagePayout(_IPFS, _HackID);
        }

    }

    //getters, restricted to view

    function GetPayoutDetails (string memory _IPFS, uint256 _HackID) external view returns (address [10] memory, uint256, uint256){
        string memory ID = string (abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        
        uint256 i;
        address[10] memory triagers;
        for (i=0; i<= TriageRequest_.TriagerCount; i++){
            triagers[i]= TriageRequest_.Triagers[i];
    }
    return (triagers, TriageRequest_.TriagePayout, TriageRequest_.TriagerCount);
    }

    function GetTriager(string memory _IPFS, uint256 _HackID, uint256 position) public view returns (address){
        string memory ID = string (abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        address triager = TriageRequest_.Triagers[position];
        return triager;
    }

    function getoutcome(string memory _IPFS, uint256 _HackID) public view returns(uint256){
        string memory ID = string (abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        return TriageRequest_.Outcome;

    }




}
