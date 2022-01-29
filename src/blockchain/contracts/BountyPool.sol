
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface MockToken_{
    function Transfer(address sender, address receiver, int amount) external;
    function GetBalance(address Account) external view returns(int);    

}



contract BountyPool {


address DeployerAddress;
constructor(address deployeraddress){
DeployerAddress=deployeraddress;
}
address SystemTokenAddress;
address TokenAddress;
address PayoutsAddress;
address UsersAddress;
address SubmittedSystemsAddress;
address TriageAddress;
address InterfaceAddress;

function SetAddress(address _SystemTokenAddress, address _TokenAddress, address _PayoutsAddress, address _UsersAddress, address _SubmittedSystemsAddress, address _TriageAddress, address _InterfaceAddress) public{
require(msg.sender==DeployerAddress);
SystemTokenAddress=_SystemTokenAddress;
TokenAddress=_TokenAddress;
PayoutsAddress=_PayoutsAddress;
UsersAddress= _UsersAddress;
SubmittedSystemsAddress= _SubmittedSystemsAddress;
TriageAddress= _TriageAddress;
InterfaceAddress=_InterfaceAddress;

}




struct BountyStaker {

    uint AmountStaked;

}

mapping (address => BountyStaker) public Stakers;

uint TotalPool;
uint DailyPoolContributions;
uint dailyearnings;

function StakeBounty(int amount, address staker) external {

  int totalbalance = MockToken_(TokenAddress).GetBalance(PayoutsAddress);
  int sharesamount = MockToken_(SystemTokenAddress).GetBalance(address(this));

  int amounttomint=amount*(sharesamount/totalbalance);



    
}

function WithdrawBounty(uint amount, address staker) external{

    int totalbalance = MockToken_(TokenAddress).GetBalance(PayoutsAddress);
    int sharesamount = MockToken_(SystemTokenAddress).GetBalance(address(this));

    int amountToRealease = usershares/totalshares * totalbalance;

}

function DistributeEarnings() public {
    

}



}