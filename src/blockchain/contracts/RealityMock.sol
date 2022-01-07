//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
contract RealityMock {

function askQuestion(
   uint256 template_id,
   string memory question,
   address arbitrator,
   uint32 timeout,
   uint32 opening_ts,
   uint256 nonce ) external returns (bytes32 question_id){

       question_id= bytes32("testinput");

       return question_id;

}

   function resultFor(bytes32 question_id) external view returns(bytes32){

       bytes32 answer;
       answer = bytes32(uint(2));
       return answer;
   }


}