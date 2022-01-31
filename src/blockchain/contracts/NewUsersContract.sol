//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

interface SubmittedSystems {
    function GetAuditWindow(string memory IPFS) external view returns (uint256);

    function GetAuditor(string memory IPFS) external view returns (address);

    function GetPayout(string memory IPFS) external view returns (uint256);

    function GetOutcome(string memory IPFS) external view returns (uint256);
}

contract NewUsersContract is Ownable {
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

    struct Auditor {
        mapping(uint256 => string) AuditedContract;
        uint256 ContractCounter;
        int256 Score;
    }

    mapping(address => Auditor) public Auditors;

    function UpdateAuditedContracts(address auditor, string memory IPFS)
        external
    {
        Auditor storage Auditor_ = Auditors[auditor];
        Auditor_.ContractCounter++;
        Auditor_.AuditedContract[Auditor_.ContractCounter] = IPFS;
    }

    int256 totalscore;
    int256 totalusers;

    function GetScore(address auditor) public returns (int256) {
        Auditor storage Auditor_ = Auditors[auditor];
        int256 currentscore = Auditor_.Score;
        //tallies score every time it is requested (is this too expensive?)
        uint256 i;
        for (i = 0; i < Auditor_.ContractCounter + 1; i++) {
            int256 outcome = int256(
                SubmittedSystems(SubmittedSystemsAddress).GetOutcome(
                    Auditor_.AuditedContract[i]
                )
            );
            // uint AuditWindow = SubmittedSystems(SubmittedSystemsAddress).GetAuditWindow(Auditor_.AuditedContract[i]);

            if (
                (outcome == 0 || outcome == 1) /*&&(block.timestamp > AuditWindow)*/
            ) {
                outcome = int256(outcome);
                Auditor_.Score = Auditor_.Score + outcome;
            } else if (
                outcome > 1 /*&& block.timestamp > AuditWindow*/
            ) {
                outcome = int256(outcome);
                Auditor_.Score = Auditor_.Score - (outcome * 10);
            }
        }

        if (currentscore != Auditor_.Score) {
            totalscore = totalscore + (currentscore - Auditor_.Score);
        }
        if (Auditor_.ContractCounter == 1 && Auditor_.Score >= 1) {
            totalusers++;
        }
        return Auditor_.Score;
    }

    function ViewScore(address auditor) public view returns (int256) {
        Auditor storage Auditor_ = Auditors[auditor];
        return Auditor_.Score;
    }

    function SetAuditorScore(address auditor) public onlyOwner {
        Auditor storage Auditor_ = Auditors[auditor];
        Auditor_.Score = 100;
    }

    struct Hacker {
        mapping(uint256 => string) IPFS;
        uint256 Counter;
        int256 Score;
    }

    struct Triager {
        bool IsTriager;
        int256 Score;
        uint256 position;
    }

    mapping(address => Triager) public Triagers;
    mapping(uint256 => address) public TriagersList;
    uint256 TriageCounter;

    function UpdateAvailableTriagers(address user, bool selection) external {
        Triager storage Triager_ = Triagers[user];

        // Adding a triager
        // if (GetScore(user) > 50 && selection == true && Triager_.IsTriager != true){
        if (
            ViewScore(user) > 50 &&
            selection == true &&
            Triager_.IsTriager != true
        ) {
            Triager_.IsTriager = selection;
            TriageCounter++;
            TriagersList[TriageCounter] = user;
            Triager_.position = TriageCounter;
        }
        // Removing a triager
        else if (selection == false && Triager_.IsTriager == true) {
            Triager_.IsTriager = false;
            TriagersList[Triager_.position] = TriagersList[TriageCounter];
            Triager storage Triager1_ = Triagers[TriagersList[TriageCounter]];
            Triager1_.position = Triager_.position;
            TriageCounter--;
        }
    }

    function GetAvailableTriager(uint256 position)
        external
        view
        returns (address)
    {
        require(position <= TriageCounter);
        return TriagersList[position];
    }

    function GetTriageCounter() external view returns (uint256) {
        return TriageCounter;
    }

    struct Overall {
        int256 Score;
    }
}
