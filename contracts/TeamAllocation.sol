pragma solidity ^0.4.11;
import './PillarToken.sol';
import './zeppelin/SafeMath.sol';
import './zeppelin/ownership/Ownable.sol';

contract TeamAllocation is Ownable {
  using SafeMath for uint;
  uint public constant totalAllocationTokens = 24000000;
  uint public remainingAllocationTokens = 3000000;
  uint public unlockedAt;
  PillarToken plr;
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
    /*
    * THESE ARE DUMMY ADDRESSES - Will be replaced before deploying to mainnet.
    */
    allocations[0x65a5A157F5097b5820A8f742f4432344f9dC94E7] = 100000;
    allocations[0x9624F5f8fA60107828A491252e62E20adA2b24FC] = 230000;
    allocations[0x2DA8e0F841BeDf46bb7689F7dc7F768802F1B9C5] = 570000;
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
    plr.transfer(msg.sender, toTransfer);
  }
}
