pragma solidity ^0.4.10;

import './MembershipToken.sol';
import './SafeMath.sol';

contract TeamAllocation {
  using SafeMath for uint;
  uint256 public constant totalAllocations = 600000;
  MembershipToken tta;
  uint256 public unlockedAt;
  mapping (address => uint256) allocations;

  uint256 tokensCreated = 0;

  function TeamAllocation(address _membershipTokenFactory) internal {
    tta = MembershipToken(msg.sender);
    // Locked time of approximately 9 months before team members are able to redeeem tokens.
    unlockedAt = now + 9 * 30 days;

    // This is an example for allocating to team members. Need to replace with actual addresses and check percentage for each team member.
    allocations[0x00] =  120000;
    allocations[0x00] =  120000;
    allocations[0x00] =  120000;
    allocations[0x00] =  120000;
    allocations[0x00] =  120000;
  }

  function getTotalAllocation()returns(uint256){
      return totalAllocations;
  }

  function unlock() external {
    if (now < unlockedAt) throw;

    if (tokensCreated == 0) {
      tokensCreated = tta.balanceOf(this);
    }

    var allocation = allocations[msg.sender];
    allocations[msg.sender] = 0;
    var toTransfer = tokensCreated * allocation / totalAllocations;

    // fail if allocation is 0
    if (!tta.transfer(msg.sender, toTransfer)) throw;
  }
}
