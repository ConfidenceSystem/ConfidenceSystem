//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface NewUsers {
    function GetAvailableTriager(uint256 _position) external returns (address);

    function GetTriageCounter() external returns (uint256);

    function UpdateTriagerScores(
        address[] memory triagers,
        int256 score,
        uint256 len
    ) external;
}

interface Payouts {
    function TriagePayout(string memory _IPFS, uint256 _HackID) external;
}

interface SubmittedSystem {
    function SetOutcome(string memory _IPFS, uint256 outcome) external;
}

contract TriageContract {
    address DeployerAddress;

    constructor(address deployeraddress) {
        DeployerAddress = deployeraddress;
    }

    address TokenAddress;
    address PayoutsAddress;
    address UsersAddress;
    address SubmittedSystemsAddress;
    address TriageAddress;
    address InterfaceAddress;

    function SetAddress(
        address _TokenAddress,
        address _PayoutsAddress,
        address _UsersAddress,
        address _SubmittedSystemsAddress,
        address _TriageAddress,
        address _InterfaceAddress
    ) public {
        require(msg.sender == DeployerAddress);
        TokenAddress = _TokenAddress;
        PayoutsAddress = _PayoutsAddress;
        UsersAddress = _UsersAddress;
        SubmittedSystemsAddress = _SubmittedSystemsAddress;
        TriageAddress = _TriageAddress;
        InterfaceAddress = _InterfaceAddress;
    }

    struct TriageRequest {
        string IPFS;
        uint256 HackID;
        uint256 TriageWindowEnd;
        uint256 TriagerCount;
        mapping(uint256 => address) Triagers;
        mapping(address => uint256) Vote;
        uint256 Outcome;
        uint256 TriagePayout;
    }

    mapping(string => TriageRequest) public TriageRequests;

    function MakeTriageRequest(
        string memory _IPFS,
        uint256 _HackID,
        uint256 _TriagerCount,
        bool dispute
    ) public {
        //setting request details
        string memory ID;
        if (dispute == true) {
            ID = string(abi.encode(_IPFS, _HackID, "D"));
        } else {
            ID = string(abi.encode(_IPFS, _HackID));
        }
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        TriageRequest_.IPFS = _IPFS;
        TriageRequest_.HackID = _HackID;
        TriageRequest_.TriagerCount = _TriagerCount;
        TriageRequest_.TriagePayout = 100; // we can change this later
        TriageRequest_.TriageWindowEnd = block.timestamp + 100; // starts triage window, will figure out equivalent of 3 days in unix time
        TriageRequest_.Outcome = 0;
        GetTriagers(ID);
    }

    function GetTriagers(string memory ID) internal {
        TriageRequest storage TriageRequest_ = TriageRequests[ID];

        uint256 randomness = uint256(blockhash(block.number)); // will do chainlink mocks later
        uint256 i;
        uint256 TriageCounter = NewUsers(UsersAddress).GetTriageCounter();
        for (i = 0; i < TriageRequest_.TriagerCount; i++) {
            TriageRequest_.Triagers[i] = NewUsers(UsersAddress)
                .GetAvailableTriager(
                    uint256(keccak256(abi.encode(randomness, i))) %
                        TriageCounter
                ); // Getting random triagers
        }
    }

    function Vote(
        string memory _IPFS,
        uint256 _HackID,
        uint256 vote,
        address triager
    ) public {
        require(msg.sender == triager);
        string memory ID = string(abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        TriageRequest_.Vote[triager] = vote;
    }

    function GetVoteOutcome(
        string memory _IPFS,
        uint256 _HackID,
        bool dispute
    ) public {
        string memory ID;
        if (dispute == true) {
            ID = string(abi.encode(_IPFS, _HackID, "D"));
        } else {
            ID = string(abi.encode(_IPFS, _HackID));
        }
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        require(TriageRequest_.Outcome == 0);
        require(block.timestamp > TriageRequest_.TriageWindowEnd);
        uint256 i;
        uint256[] memory tally;
        address[] memory triagers;
        for (i = 0; i < TriageRequest_.TriagerCount; i++) {
            address triager = TriageRequest_.Triagers[i];
            triagers[i] = triager;
            tally[TriageRequest_.Vote[triager]]++; //get triagers vote, and tallies that position in array
            if (
                tally[TriageRequest_.Vote[triager]] ==
                (TriageRequest_.TriagerCount)
            ) {
                //if the amount of votes on certain severity == amount of triagers, sets outcome to that severity
                TriageRequest_.Outcome = TriageRequest_.Vote[triager];
            }
        }
        if (TriageRequest_.Outcome == 0) {
            MakeTriageRequest(
                _IPFS,
                _HackID,
                TriageRequest_.TriagerCount,
                false
            );
            //if consensus is not met, overwrites and gets new triagers
        } else {
            SubmittedSystem(SubmittedSystemsAddress).SetOutcome(
                _IPFS,
                TriageRequest_.Outcome
            );
            Payouts(PayoutsAddress).TriagePayout(_IPFS, _HackID);
            int256 score = 1;
            uint256 len = TriageRequest_.TriagerCount;
            NewUsers(UsersAddress).UpdateTriagerScores(triagers, score, len);
        }
    }

    function Dispute(string memory _IPFS, uint256 _HackID) internal {
        address[] memory triagers;
        string memory DisputeID = string(abi.encode(_IPFS, _HackID, "D"));
        string memory ID = string(abi.encode(_IPFS, _HackID));

        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        TriageRequest storage TriageDispute_ = TriageRequests[DisputeID];

        if (TriageRequest_.Outcome != TriageDispute_.Outcome) {
            uint256 i;
            for (i = 0; i < TriageRequest_.TriagerCount; i++) {
                triagers[i] = TriageRequest_.Triagers[i];
            }
            int256 score = -10;
            uint256 len = TriageRequest_.TriagerCount;

            NewUsers(UsersAddress).UpdateTriagerScores(triagers, score, len);
        }
    }

    //getters, restricted to view

    function GetPayoutDetails(string memory _IPFS, uint256 _HackID)
        external
        view
        returns (
            address[10] memory,
            uint256,
            uint256
        )
    {
        string memory ID = string(abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];

        uint256 i;
        address[10] memory triagers;
        for (i = 0; i <= TriageRequest_.TriagerCount; i++) {
            triagers[i] = TriageRequest_.Triagers[i];
        }
        return (
            triagers,
            TriageRequest_.TriagePayout,
            TriageRequest_.TriagerCount
        );
    }

    function GetTriager(
        string memory _IPFS,
        uint256 _HackID,
        uint256 position
    ) public view returns (address) {
        string memory ID = string(abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        address triager = TriageRequest_.Triagers[position];
        return triager;
    }

    function getoutcome(string memory _IPFS, uint256 _HackID)
        public
        view
        returns (uint256)
    {
        string memory ID = string(abi.encode(_IPFS, _HackID));
        TriageRequest storage TriageRequest_ = TriageRequests[ID];
        return TriageRequest_.Outcome;
    }
}
