pragma solidity ^0.4.8;

import './SafeMath.sol';
import './Ownable.sol';
import './PillarToken.sol';

contract TeamAllocation is Ownable {
  using SafeMath for uint;
  PillarToken plr;
  uint public constant totalAllocationTokens = 3000000;
  uint public remainingAllocationTokens = 3000000;
  uint public unlockedAt;
  mapping (address => uint) allocations;
  address[] members;

  uint tokensCreated = 0;

  /*
    Split among team members
    Tokens reserved for Team: 1,000,000
    Tokens reserved for 20|30 projects: 1,000,000
    Tokens reserved for future sale: 1,000,000
  */

  function TeamAllocation() {
    plr = PillarToken(msg.sender);
    // Locked time of approximately 9 months before team members are able to redeeem tokens.
    uint nineMonths = 9 * 30 days;
    unlockedAt = now.add(nineMonths);
    //member allocations hardcoded
  }
/*
  function assignTokensToTeamMember(address _teamMemberAddress,uint _tokens) onlyOwner returns(bool){
    if(remainingAllocationTokens >= _tokens){
      remainingAllocationTokens = remainingAllocationTokens - _tokens;
      allocations[_teamMemberAddress] =  _tokens;
      members.push(_teamMemberAddress);
      return true;
    }
    return false;
  }
*/
  function getTotalAllocation()returns(uint){
      return totalAllocationTokens;
  }

  function unlock() external payable {
    if (now < unlockedAt) throw;

    if (tokensCreated == 0) {
      tokensCreated = plr.balanceOf(this);
    }

    var allocation = allocations[msg.sender];
    allocations[msg.sender] = 0;
    var toTransfer = (tokensCreated.mul(allocation)).div(totalAllocationTokens);

    // fail if allocation is 0
    if (!plr.transfer(msg.sender, toTransfer)) throw;
  }
}
