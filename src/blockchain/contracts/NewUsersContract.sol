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

    int256 totalscore;
    int256 totalusers;

    function UpdateHackerScore(address _Hacker, uint256 _Amount) public {
        require(msg.sender==PayoutsAddress);
        Hacker storage Hacker_ = Hackers[_Hacker];
        Hacker_.Score = Hacker_.Score + _Amount;
    }

    function ViewScore(address _Hacker) public view returns (uint256) {
        Hacker storage Hacker_ = Hackers[_Hacker];
        return Hacker_.Score;
    }

    function SetHackerScore(address _Hacker) public onlyOwner {
        Hacker storage Hacker_ = Hackers[_Hacker];
        Hacker_.Score = 100;
    }

    struct Hacker {
        mapping(uint256 => string) IPFS;
        uint256 Counter;
        uint256 Score;
    }

    struct Triager {
        bool IsTriager;
        int256 Score;
        uint256 position;
    }

    mapping(address => Triager) public Triagers;
    mapping(address => Hacker) public Hackers;

    mapping(uint256 => address) public TriagersList;
    uint256 TriageCounter;

    function UpdateAvailableTriagers(address user, bool selection) external {
        Triager storage Triager_ = Triagers[user];

        // Adding a triager
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
