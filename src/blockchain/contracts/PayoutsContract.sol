//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface newsubmittedsystems {
    function GetAuditWindow(string memory IPFS) external view returns (uint256);
    
    function AuditorPaid(string memory IPFS) external;

    function GetAuditorPaid(string memory IPFS) external view returns (bool);

    function GetOutcome(string memory IPFS) external view returns (uint256);

    function UpdateSystemsUnderAudit() external;

    function GetBounty(string memory IPFS) external view returns (uint256);

    function HackPayoutDetails(string memory IPFS)
        external
        view
        returns (
            uint256,
            address[] memory,
            uint256[] memory
        );
}

interface Triage {
    function GetPayoutDetails(string memory _IPFS, uint256 _HackID)
        external
        view
        returns (
            address[10] memory,
            uint256,
            uint256
        );
}

interface Users {
    function UpdateHackerScore(address _Hacker, uint256 _Amount) external; 

}

contract PayoutsContract {
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

   
    function BountyPayout(string memory IPFS) external {
        require(
            newsubmittedsystems(SubmittedSystemsAddress).GetAuditorPaid(IPFS) !=
                true
        );
        newsubmittedsystems(SubmittedSystemsAddress).AuditorPaid(IPFS);

        uint256 counter;
        address[] memory hackers;
        uint256[] memory outcomes;
        uint256 severitytotal;
        uint256 i;
        uint256 bounty = newsubmittedsystems(SubmittedSystemsAddress).GetBounty(
            IPFS
        );

        (counter, hackers, outcomes) = newsubmittedsystems(
            SubmittedSystemsAddress
        ).HackPayoutDetails(IPFS);

        for (i = 0; i <= counter; i++) {
            severitytotal = severitytotal + outcomes[i];
        }

        for (i = 0; i <= counter; i++) {
            uint256 payout = bounty * (outcomes[i] / severitytotal);
            if (payout > 0) {
                IERC20(MockStableCoin).transferFrom(
                    address(this),
                    hackers[i],
                    payout
                );
            Users(UsersAddress).UpdateHackerScore(hackers[i], outcomes[i]);
            }
        }
    }

    function TriagePayout(string memory _IPFS, uint256 _HackID) external {
        address[10] memory triagers;
        uint256 payout;
        uint256 triagercount;
        (triagers, payout, triagercount) = Triage(TriageAddress)
            .GetPayoutDetails(_IPFS, _HackID);

        uint256 i;
        uint256 triagerpayout = (payout / triagercount);

        for (i = 0; i < triagercount; i++) {
            IERC20(MockStableCoin).transferFrom(
                address(this),
                triagers[i],
                (triagerpayout)
            );
        }
    }
}
