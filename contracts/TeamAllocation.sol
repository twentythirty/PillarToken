pragma solidity ^0.4.11;
import './PillarToken.sol';
import './zeppelin/SafeMath.sol';
import './zeppelin/ownership/Ownable.sol';

contract TeamAllocation is Ownable {
  using SafeMath for uint;
  //uint public constant lockedTeamAllocationTokens = 16000000;
  uint public unlockedAt;
  PillarToken plr;
  mapping (address => uint) allocations;
  address[] members;

  uint tokensCreated = 0;
  //address of the team storage vault
  address public constant teamStorageVault = 0x45B0852F3fC6fB50e3898f7A38184f66efC53137;

  function TeamAllocation() {
    plr = PillarToken(msg.sender);
    // Locked time of approximately 9 months before team members are able to redeeem tokens.
    uint nineMonths = 9 * 30 days;
    unlockedAt = now.add(nineMonths);
    //2% tokens from the Marketing bucket which are locked for 9 months
    allocations[teamStorageAddress] = plr.lockedTeamAllocationTokens;
  }

  function getTotalAllocation()returns(uint){
      return plr.lockedTeamAllocationTokens;
  }

  function unlock() external payable {
    if (now < unlockedAt) throw;

    if (tokensCreated == 0) {
      tokensCreated = plr.balanceOf(this);
    }
    //transfer the locked tokens to the teamStorageAddress
    plr.transfer(teamStorageVault, tokensCreated);
  }
}
