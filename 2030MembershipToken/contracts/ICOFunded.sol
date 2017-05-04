pragma solidity ^0.4.10;

import './SafeMath.sol';
import './TeamAllocation.sol';

contract ICOFunded {
  TeamAllocation tAll;
  TeamAllocation public lockedAllocation;

  uint256  public constant totaNumberOfToken = 4000000;

  uint256  public constant tokenCreationRate = 50;

  address public membershipTokenFactory;

  // Minimum token creation
  uint256 public constant tokenCreationMin = 1000000;
  uint256 public constant reservedTokensForAllocation = 600000;

  //total token - member token
  uint256  public constant totalTokenOffer = totaNumberOfToken - reservedTokensForAllocation;

  uint256 public salePeriod;

  uint256 fundingStartBlock;
  uint256 fundingStopBlock;
  // flags whether ICO is afoot.
  bool fundingMode = true;

  //total tokens supply
  uint256 totalTokens;

  mapping (address => uint256) balances;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Refund(address indexed _from,uint256 _value);

  function ICOFunded(address _membershipTokenFactory, uint256 _fundingStartBlock, uint256 _fundingStopBlock, address _migrationMaster) {

    //sale peioriod
    salePeriod = now + 16 days;

    membershipTokenFactory = _membershipTokenFactory;
    migrationMaster = _migrationMaster;
    fundingStartBlock = _fundingStartBlock;
    fundingStopBlock = _fundingStopBlock;
  }

  function checkSalePeriod() external constant returns (uint256) {
    return salePeriod;
  }

  function totalSupply() external constant returns (uint256) {
    return totalTokens;
  }

  function balanceOf(address owner) external constant returns (uint256) {
    return balances[owner];
  }

  // ICO
  function fundingActive() constant external returns (bool){
    if(!fundingMode) return false;

    if(block.number < fundingStartBlock || block.number > fundingStopBlock || totalTokenOffer >= tokenCreationMin){
      return false;
    }
    return true;
  }

  function numberOfTokensLeft() constant external returns (uint256) {
    if (!fundingMode) return 0;
    if (block.number > fundingStopBlock) {
      return 0;
    }
    return totalTokenOffer - totalTokens;
  }

  function isFinalized() constant external returns (bool){
    return !fundingMode;
  }

  function() payable external {
    if(!fundingMode) throw;
    if(block.number < fundingStartBlock) throw;
    if(block.number > fundingStopBlock) throw;
    if(totalTokens >= totalTokenOffer) throw;

    if (msg.value == 0) throw;

    var numTokens = msg.value * tokenCreationRate;
    totalTokens += numTokens;
    if (totalTokens > totalTokenOffer) throw;

    // Assign new tokens to sender
    balances[msg.sender] += numTokens;

    // log token creation event
    Transfer(0, msg.sender, numTokens);
  }

  function finalize() external {
    if (!fundingMode) throw;
    if ((block.number <= fundingStopBlock ||
      totalTokens < tokenCreationMin) &&
      totalTokens < totalTokenOffer) throw;

      // switch funding mode off
      fundingMode = false;

      if (!membershipTokenFactory.send(this.balance)) throw;

      /*uint256 percentOfTotal = */
      totalTokens += reservedTokensForAllocation;
      balances[lockedAllocation] += reservedTokensForAllocation;
      Transfer(0, lockedAllocation, reservedTokensForAllocation);
  }

  function refund() external {

    if(!fundingMode) throw;
    if(block.number <= fundingStopBlock) throw;
    if(totalTokens >= tokenCreationMin) throw;

    var ttaValue= balances[msg.sender];
    if(ttaValue == 0) throw;

    balances[msg.sender] = 0;

    totalTokens -= ttaValue;

    var ethValue = ttaValue / tokenCreationRate;
    if(!msg.sender.send(ethValue)) throw;
    Refund(msg.sender, ethValue);
  }
}
