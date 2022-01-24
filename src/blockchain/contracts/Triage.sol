pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface NewUsers {
function GetAvailableTriager(uint position) external returns(address);

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

    function MakeTriageRequest(string memory IPFS, uint HackID, uint TriagerCount) external {

        //setting request details
        TriageRequest storage TriageRequest_ = TriageRequests[abi.encode(IPFS, HackID)];
        TriageRequest_.IPFS=IPFS;
        TriageRequest_.HackID=HackID;
        TriageRequest.TriagerCount=TriagerCount;
        TriageRequest_.TriageWindowEnd=block.timestamp+100; //starts triage window, will figure out equivalent of 3 days in unix time

        //getting triagers
        uint randomness = uint(blockhash(block.number)); //will do chainlink mocks later
        uint i;
        for (i=1; i<=TriagerCount; i++){
        TriageRequest_.Triagers[i]=NewUsers(UserAddres).GetAvailableTriager(uint(keccak256(abi.encode(randomness, i))) % TriagerCount);
        }

    }

    function CommitVoteHash(string memory IPFS, uint HackID) external {

    }

    function RevealVote() external {

    }





}