//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Users {
    function GetScore(address auditor) external returns (int256);

    function UpdateAuditedContracts(address auditor, string memory IPFS)
        external;
}

interface Triage {
    function MakeTriageRequest(
        string memory _IPFS,
        uint256 _HackID,
        uint256 _TriagerCount
    ) external;
}

contract SubmittedSystemsContract {
    address DeployerAddress;

    constructor(address deployeraddress) {
        DeployerAddress = deployeraddress;
    }

    address MockStableCoin;
    address PayoutsAddress;
    address UsersAddress;
    address SubmittedSystemsAddress;
    address TriageAddress;
    address InterfaceAddress;

    function SetAddress(
        address _MockStableCoin,
        address _PayoutsAddress,
        address _UsersAddress,
        address _SubmittedSystemsAddress,
        address _TriageAddress,
        address _InterfaceAddress
    ) public {
        require(msg.sender == DeployerAddress);
        MockStableCoin = _MockStableCoin;
        PayoutsAddress = _PayoutsAddress;
        UsersAddress = _UsersAddress;
        SubmittedSystemsAddress = _SubmittedSystemsAddress;
        TriageAddress = _TriageAddress;
        InterfaceAddress = _InterfaceAddress;
    }

    struct SubmittedSystem {
        uint256 AuditWindowEnd;
        uint256 Bounty;
        bool Paid;
        uint256 Outcome; //numbers correspond to outcome details (0=still under audit) (1=no vulns found) (2-6 = vulns found(higher = more severe))
        int256 MinScore;
        bool SetDetails;
        address SubmitterAddress;
    }

    struct SubmittedSystemHack {
        mapping(address => mapping(uint256 => string)) HackHash;
        mapping(address => mapping(uint256 => string)) HackURI;
        mapping(address => mapping(uint256 => uint256)) HackOutcome; //0-5, gauging severity, 0 being spam, 5 being crit vuln
        mapping(address => uint256) AddressLocalHackCounter;
        mapping(uint256 => address) HackCounterAddress;
        mapping(uint256 => uint256) HackCounterAddressID;
        uint256 HackCounter;
    }

    mapping(string => SubmittedSystem) public SubmittedSystems;
    mapping(string => SubmittedSystemHack) public SubmittedSystemHacks;

    function HackPayoutDetails(string memory IPFS)
        public
        view
        returns (
            uint256,
            address[] memory,
            uint256[] memory
        )
    {
        SubmittedSystemHack storage System_ = SubmittedSystemHacks[IPFS];
        uint256 counter = System_.HackCounter;
        uint256 i;
        address local;
        uint256 ID;
        uint256 outcome;
        address[] memory IDs;
        uint256[] memory outcomes;

        for (i = 0; i <= counter; i++) {
            local = System_.HackCounterAddress[i];
            ID = System_.HackCounterAddressID[i];
            outcome = System_.HackOutcome[local][ID];

            if (outcome > 0) {
                IDs[i] = local;
                outcomes[i] = outcome;
            }
        }
        return (counter, IDs, outcomes);
    }

    uint256 systemsunderaudit;

    function SubmitSystem(
        string memory IPFS,
        int256 MinAuditorScore,
        uint256 Payout,
        address Submitter
    ) public {
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        require(SubmittedSystem_.SetDetails != true);
        SubmittedSystem_.SetDetails = true;
        SubmittedSystem_.Outcome = 1;
        IERC20(MockStableCoin).transferFrom(Submitter, PayoutsAddress, Payout); // puts money in escrow
        SubmittedSystem_.SubmitterAddress = Submitter;
        SubmittedSystem_.MinScore = MinAuditorScore;
        systemsunderaudit++;
    }

    function StartTimeWindow(string memory IPFS, uint length) public {
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        require(msg.sender==SubmittedSystem_.SubmitterAddress);
        SubmittedSystem_.AuditWindowEnd = block.timestamp + length; 
    }

    function AuditorPaid(string memory IPFS) external {
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        SubmittedSystem_.Paid = true;
    }

    function SubmitHackHash(
        string memory IPFS,
        string memory HackHash,
        address HackSubmitter
    ) external returns (uint256) {
        SubmittedSystemHack storage SubmittedSystemHack_ = SubmittedSystemHacks[
            IPFS
        ];

        SubmittedSystemHack_.HackCounter++; //overall hack counter and ID for system
        SubmittedSystemHack_.AddressLocalHackCounter[HackSubmitter]++; //local hack counter and ID for each user that submits vulns

        SubmittedSystemHack_.HackCounterAddress[
            SubmittedSystemHack_.HackCounter
        ] = HackSubmitter; //address of vuln submitter for this ID
        SubmittedSystemHack_.HackCounterAddressID[
            SubmittedSystemHack_.HackCounter
        ] = SubmittedSystemHack_.AddressLocalHackCounter[HackSubmitter]; //where in user's submitted vulns this vuln is. i.e position 4

        SubmittedSystemHack_.HackHash[HackSubmitter][
            SubmittedSystemHack_.AddressLocalHackCounter[HackSubmitter]
        ] = HackHash; //submitting hack hash
        return SubmittedSystemHack_.HackCounter; //returning Hack ID
    }

    function SubmitHackURI(
        string memory IPFS,
        string memory HackURI,
        address HackSubmitter,
        uint256 HackID
    ) external {
        SubmittedSystemHack storage SubmittedSystemHack_ = SubmittedSystemHacks[
            IPFS
        ];

        uint256 LocalHackID = SubmittedSystemHack_.HackCounterAddressID[HackID]; //getting address specific hack position/id
        SubmittedSystemHack_.HackURI[HackSubmitter][LocalHackID] = HackURI; //submitting URI

        Triage(TriageAddress).MakeTriageRequest(IPFS, HackID, 4); //making triage request
    }

    function SetOutcome(string memory IPFS, uint256 outcome) public {
        require(msg.sender == (address(this)) || msg.sender == TriageAddress);
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        require(block.timestamp < SubmittedSystem_.AuditWindowEnd);
        require(outcome > SubmittedSystem_.Outcome);
        SubmittedSystem_.Outcome = outcome;
    }

    function UpdateSystemsUnderAudit() external {
        systemsunderaudit--;
    }

    //Getters, all restricted to view.

    function GetOutcome(string memory IPFS) external view returns (uint256) {
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        return SubmittedSystem_.Outcome;
    }

    function GetAuditorPaid(string memory IPFS) external view returns (bool) {
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        return SubmittedSystem_.Paid;
    }

    function GetBounty(string memory IPFS) external view returns (uint256) {
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        return SubmittedSystem_.Bounty;
    }

    function GetAuditWindow(string memory IPFS)
        external
        view
        returns (uint256)
    {
        SubmittedSystem storage SubmittedSystem_ = SubmittedSystems[IPFS];
        return SubmittedSystem_.AuditWindowEnd;
    }
}
