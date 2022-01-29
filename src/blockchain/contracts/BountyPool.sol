
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface FidesTokenContract{
    function mint (uint amount, address receiver) external;
    function burn (uint amount, address receiver) external;
}



contract BountyPool {


address DeployerAddress;
constructor(address deployeraddress){
DeployerAddress=deployeraddress;
}
address FidesToken;
address MockStableCoin;
address PayoutsAddress;
address UsersAddress;
address SubmittedSystemsAddress;
address TriageAddress;
address InterfaceAddress;

function SetAddress(address _FidesToken, address _MockStableCoin, address _PayoutsAddress, address _UsersAddress, address _SubmittedSystemsAddress, address _TriageAddress, address _InterfaceAddress) public{
require(msg.sender==DeployerAddress);
FidesToken=_FidesToken;
MockStableCoin=_MockStableCoin;
PayoutsAddress=_PayoutsAddress;
UsersAddress= _UsersAddress;
SubmittedSystemsAddress= _SubmittedSystemsAddress;
TriageAddress= _TriageAddress;
InterfaceAddress=_InterfaceAddress;

}


function StakeBounty(uint _Amount, address _Staker) external {

  uint Totalbalance = IERC20(MockStableCoin).balanceOf(PayoutsAddress);
  uint Sharesamount = IERC20(FidesToken).totalSupply();

  if(Totalbalance==0||Sharesamount==0){
    IERC20(MockStableCoin).transferFrom(_Staker, PayoutsAddress, _Amount);
    FidesTokenContract(FidesToken).mint(_Amount, _Staker);

  }
  else{
    uint what = _Amount * (Sharesamount/Totalbalance);
    IERC20(MockStableCoin).transferFrom(_Staker, PayoutsAddress, _Amount);
    FidesTokenContract(FidesToken).mint(what, _Staker);
  }

}

function Withdraw(uint _Amount, address _Staker) external{
    
uint Totalbalance = IERC20(MockStableCoin).balanceOf(PayoutsAddress);
uint Sharesamount = IERC20(FidesToken).totalSupply();

uint payout = _Amount * (Totalbalance/Sharesamount);
IERC20(MockStableCoin).transferFrom(PayoutsAddress, _Staker, payout);
FidesTokenContract(FidesToken).burn(_Amount, _Staker);


}


}