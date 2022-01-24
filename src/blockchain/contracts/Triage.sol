pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface NewUsers {
function GetAvailableTriager(uint _position) external returns(address);

}
contract TriageContract {

    struct TriageRequest {
        string IPFS;
        uint HackID;
        uint TriageWindowEnd;
        uint TriagerCount;
        mapping (uint => address) Triagers;
        mapping (uint => uint) vote; //severity mapping to amount of votes

    }

    mapping (string => TriageRequest) public TriageRequests;

    function MakeTriageRequest(string memory _IPFS, uint _HackID, uint _TriagerCount) external {

        //setting request details
        TriageRequest storage TriageRequest_ = TriageRequests[abi.encode(_IPFS, _HackID)];
        TriageRequest_.IPFS = _IPFS;
        TriageRequest_.HackID = _HackID;
        TriageRequest.TriagerCount = _TriagerCount;
        TriageRequest_.TriageWindowEnd = block.timestamp+100; // starts triage window, will figure out equivalent of 3 days in unix time

        //getting triagers
        uint randomness = uint(blockhash(block.number)); // will do chainlink mocks later
        uint i;
        for (i = 0; i <= TriagerCount; i++) {
        TriageRequest_.Triagers[i] = NewUsers(UserAddres).GetAvailableTriager(uint(keccak256(abi.encode(randomness, i))) % TriagerCount);
        }

    }

    function CommitVoteHash(string memory _IPFS, uint _HackID) external {

    }

    function RevealVote() external {

    }





}
