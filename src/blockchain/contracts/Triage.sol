pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface NewUsers {
function GetAvailableTriager(uint _position) external returns(address);
function GetTriageCounter()external returns(uint);
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
        uint HackID;
        uint TriageWindowEnd;
        uint TriagerCount;
        mapping (uint => address) Triagers;
        mapping (address => string) VoteHash;
        mapping (address => uint) Vote; 
        uint Outcome;
        uint TriagePayout;
    }

    mapping (string => TriageRequest) public TriageRequests;

    function MakeTriageRequest(string memory _IPFS, uint _HackID, uint _TriagerCount) public {

        //setting request details
        TriageRequest storage TriageRequest_ = TriageRequests[abi.encode(_IPFS, _HackID)];
        TriageRequest_.IPFS = _IPFS;
        TriageRequest_.HackID = _HackID;
        TriageRequest.TriagerCount = _TriagerCount;
        TriageRequest_.TriagePayout=100; // we can change this later
        TriageRequest_.TriageWindowEnd = block.timestamp+100; // starts triage window, will figure out equivalent of 3 days in unix time
        TriageRequest_.Outcome=9; //0 is in use as a valid outcome, so this just signifies that consensus hasn't been found yet
        //getting triagers
        uint randomness = uint(blockhash(block.number)); // will do chainlink mocks later
        uint i;
        uint TriageCounter = NewUsers(UserAddres).GetTriageCounter();
        for (i = 0; i <= TriageCounter; i++) {
        TriageRequest_.Triagers[i] = NewUsers(UserAddres).GetAvailableTriager(uint(keccak256(abi.encode(randomness, i))) % TriageCounter);
        }

    }

    function CommitVoteHash(string memory _IPFS, uint _HackID, string memory _VoteHash, address _Triager) external {
        TriageRequest storage TriageRequest_ = TriageRequests[abi.encode(_IPFS, _HackID)];
        bool IsTriager;
        uint i;
        for (i=0; i<TriageRequest_.TriagerCount; i++){
            if (TriageRequest_.Triagers[i]==_Triager){
                IsTriager=true;
            }
        }
        if (TriageRequest_.Triagers[i]==_Triager){
         TriageRequest_.VoteHash[_Triager] = _VoteHash;
        }
    }

    function RevealVote(string memory _IPFS, uint _HackID, string memory _Vote, string memory _Nonce, address _Triager) external {
        TriageRequest storage TriageRequest_ = TriageRequests[abi.encode(_IPFS, _HackID)];
        string memory VoteHash = keccak256(abi.encode(_Vote, _Nonce, _IPFS, _HackID)); 
        require (VoteHash == TriageRequest_.VoteHash[_Triager]); //Checking Hash
        TriageRequest_.Vote[_Triager]=_Vote;

        //store used nonces and spot check
        //if you can get a Triager's vote before reveal, they are penalized and you are rewarded.
    }

    function GetVoteOutcome(string memory _IPFS, uint _HackID) external {
        TriageRequest storage TriageRequest_ = TriageRequests[abi.encode(_IPFS, _HackID)];
        require(block.timestamp > TriageRequest_.TriageWindowEnd);
        uint i;
        mapping (uint => uint) tally;
        for (i=0; i< TriageRequest_.TriagerCount; i++){
            address triager = TriageRequest_.Triagers[i];
            tally[TriageRequest_.Vote[triager]]++;
            if (tally[TriageRequest_.Vote[triager]] == TriageRequest_.TriagerCount){
                TriageRequest_.Outcome=TriageRequest_.Vote[triager];
            }

        }
        if (TriageRequest_.Outcome == 9){
            MakeTriageRequest(_IPFS, _HackID, TriageRequest_.TriagerCount);
            //if consensus is not met, overwrites and gets new triagers
        }

        NewPayouts(PayoutsAddress).TriagerPayout;

    }

    //getters, restricted to view

    function GetPayoutDetails (string memory _IPFS, string memory _HackID) external view returns (address [] memory, uint, uint){
        TriageRequest storage TriageRequest_ = TriageRequests[abi.encode(_IPFS, _HackID)];
        uint i;
        address[] triagers;
        for (i=0; i< TriageRequest_.TriagerCount; i++){
            triagers[i]= TriageRequest_.Triagers[i];
    }
    return (triagers, TriageRequest_.TriagePayout, TriageRequest_.TriagerCount);
    }




}
