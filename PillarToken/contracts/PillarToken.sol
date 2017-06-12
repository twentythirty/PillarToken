pragma solidity ^0.4.11;

import './TeamAllocation.sol';
import './zeppelin/SafeMath.sol';
import './zeppelin/token/StandardToken.sol';
import './zeppelin/ownership/Ownable.sol';

contract PillarToken is StandardToken, Ownable {

    using SafeMath for uint;
    string public constant name = "PILLAR";
    string public constant symbol = "PLR";
    //uint8 costs more gas than uint246/uint so changed the data type
    uint public constant decimals = 18;

    TeamAllocation tAll;
    TeamAllocation public lockedAllocation;

    uint constant public minTokensForSale = 3000000;
    uint constant public totalAllocationTokens = 24000000;
    /* Check ETH/USD rate on the day of the ICO */
    /* 1 ETH = 350 USD ; 1/350 of USD expressed in WEI */
    // Need to revisit this value at later point
    uint public constant tokenPrice  = 2857142857000 wei;

    //address corresponding to the pillar token factory where the fund raised will be held.
    address public pillarTokenFactory;

    //Sale Period
    uint public salePeriod;

    uint fundingStartBlock;
    uint fundingStopBlock;

    // flags whether ICO is afoot.
    bool fundingMode = true;

    //total used tokens
    uint totalUsedTokens;

    event Refund(address indexed _from,uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    modifier isFundingModeStart() {
        if (fundingMode) throw;
        _;
    }

    modifier isFundingModeStop() {
        if (!fundingMode) throw;
        _;
    }

    function PillarToken(address _pillarTokenFactory, uint256 _fundingStartBlock, uint256 _fundingStopBlock) {
      salePeriod = now.add(60 hours);
      pillarTokenFactory = _pillarTokenFactory;
      fundingStartBlock = _fundingStartBlock;
      fundingStopBlock = _fundingStopBlock;
      totalUsedTokens = 0;
      totalSupply = 560000000;
    }

    /**
    * Function to pause the ICO. Will be used for fire fighting
    */
    function pause() onlyOwner isFundingModeStop external returns (bool) {
      fundingMode = false;
    }

    /*
    * Function used to validate conditions in case the contract is called with incorrect data
    */
    function() payable isFundingModeStop external {

      if(now > salePeriod) throw;
      if(block.number < fundingStartBlock) throw;
      if(block.number > fundingStopBlock) throw;
      if(totalUsedTokens >= totalSupply) throw;

      if (msg.value == 0) throw;

      // total tokens purchased is received gas/cost of 1 token
      uint numTokens = msg.value.div(tokenPrice);
      totalUsedTokens = totalUsedTokens.add(numTokens);
      if (totalUsedTokens > totalSupply) throw;


      balances[msg.sender] = balances[msg.sender].add(numTokens);

      Transfer(0, msg.sender, numTokens);
    }

    function purchase() payable isFundingModeStop external {
      if(now > salePeriod) throw;
      if(block.number < fundingStartBlock) throw;
      if(block.number > fundingStopBlock) throw;
      if(totalUsedTokens >= totalSupply) throw;

      if (msg.value == 0) throw;

      uint numTokens = msg.value.div(tokenPrice);
      totalUsedTokens = totalUsedTokens.add(numTokens);
      if (totalUsedTokens > totalSupply) throw;

      balances[msg.sender] = balances[msg.sender].add(numTokens);

      Transfer(0, msg.sender, numTokens);
    }

    function checkSalePeriod() external constant returns (uint) {
      return salePeriod;
    }
    /*
    function totalSupply() constant returns (uint totalSupply) {
      // return totalTokens;
      totalSupply = tokensAvailableForSale;
    }
    */
    function fundingActive() constant isFundingModeStop external returns (bool){
      if(block.number < fundingStartBlock || block.number > fundingStopBlock || totalUsedTokens > totalSupply){
        return false;
      }
      return true;
    }

    function numberOfTokensLeft() constant external returns (uint256) {
      if (block.number > fundingStopBlock) {
        return 0;
      }
      uint tokensAvailableForSale = totalSupply - totalUsedTokens;
      return tokensAvailableForSale;
    }

    function isFinalized() constant external returns (bool){
      return !fundingMode;
    }


    function finalize() isFundingModeStop onlyOwner external {
      if ((block.number <= fundingStopBlock ||
        totalUsedTokens < minTokensForSale) &&
        totalUsedTokens < totalSupply) throw;

        // switch funding mode off
        fundingMode = false;

        if (!pillarTokenFactory.send(this.balance)) throw;

        totalUsedTokens = totalUsedTokens.add(totalAllocationTokens);
        balances[lockedAllocation] = balances[lockedAllocation].add(totalAllocationTokens);
        Transfer(0, lockedAllocation, totalAllocationTokens);
    }

    function refund() isFundingModeStop onlyOwner external {
      if(block.number <= fundingStopBlock) throw;
      if(totalUsedTokens >= minTokensForSale) throw;

      uint plrValue = balances[msg.sender];
      if(plrValue == 0) throw;

      balances[msg.sender] = 0;

      totalUsedTokens = totalUsedTokens.sub(plrValue);

      uint ethValue = plrValue.div(tokenPrice);
      if(!msg.sender.send(ethValue)) throw;
      Refund(msg.sender, ethValue);
    }

    //Is this required?
    function allocateTokens(address _to,uint _tokens) onlyOwner external {
      if (!fundingMode) throw;

      if ((block.number <= fundingStopBlock ||
        totalUsedTokens < minTokensForSale) &&
        totalUsedTokens < totalSupply &&
        (totalUsedTokens - _tokens) < 0) throw;

      totalUsedTokens -= _tokens;
      balances[_to] += _tokens;
    }
}
