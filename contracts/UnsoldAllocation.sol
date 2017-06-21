pragma solidity ^0.4.11;
import './PillarToken.sol';
import './zeppelin/SafeMath.sol';
import './zeppelin/ownership/Ownable.sol';

contract UnsoldAllocation is Ownable {
  using SafeMath for uint;
  uint unlockedAt;
  uint allocatedTokens;
  PillarToken plr;
  mapping (address => uint) allocations;

  uint tokensCreated = 0;

  /*
    Split among team members
    Tokens reserved for Team: 1,000,000
    Tokens reserved for 20|30 projects: 1,000,000
    Tokens reserved for future sale: 1,000,000
  */

  function TeamAllocation(uint _lockTime, address _owner, uint _tokens) {
    if(_lockTime == 0) throw;

    if(_owner == address(0)) throw;

    if(_tokens <= 0) throw;

    plr = PillarToken(msg.sender);
    if(_lockTime == 3) {
      unlockedAt = now.add(3 years);
    }
    if(_lockTime == 10) {
      unlockedAt = now.add(10 years);
    }
    allocatedTokens = _tokens;
    allocations[_owner] = _tokens;
  }

  function getTotalAllocation()returns(uint){
      return allocatedTokens;
  }

  function unlock() external payable {
    if (now < unlockedAt) throw;

    if (tokensCreated == 0) {
      tokensCreated = plr.balanceOf(this);
    }

    var allocation = allocations[msg.sender];
    allocations[msg.sender] = 0;
    var toTransfer = (tokensCreated.mul(allocation)).div(allocatedTokens);
    plr.transfer(msg.sender, toTransfer);
  }
}
