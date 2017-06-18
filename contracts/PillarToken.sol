pragma solidity ^0.4.11;

import './IcedStorage.sol';
import './TeamAllocation.sol';
import './zeppelin/SafeMath.sol';
import './zeppelin/token/StandardToken.sol';
import './zeppelin/ownership/Ownable.sol';

contract PillarToken is StandardToken, Ownable {

    using SafeMath for uint;
    string public constant name = "PILLAR";
    string public constant symbol = "PLR";
    uint public constant decimals = 18;

    IcedStorage public futureSale;
    TeamAllocation teamAllocation;

    uint constant public minTokensForSale = 3000000;
    uint constant public totalAllocationTokens = 24000000;
    uint constant public futureTokens = 120000000;
    uint constant public teamAllocationTokens = 24000000;

    // Need to revisit this value at later point
    uint public constant tokenPrice  = 1 finney;

    // address corresponding to the pillar token factory where the fund raised will be held.
    address public pillarTokenFactory;

    // Sale Period
    uint public salePeriod;

    uint fundingStartBlock;
    uint fundingStopBlock;

    /* flags whether ICO is afoot.*/
    bool fundingMode = true;

    /*total used tokens*/
    uint totalUsedTokens;

    event Refund(address indexed _from,uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    modifier isNotFundable() {
        if (fundingMode) throw;
        _;
    }

    modifier isFundable() {
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

    /*
    * Function to pause the ICO. Will be used for fire fighting
    */
    function pause() onlyOwner isFundable external returns (bool) {
      fundingMode = false;
    }

    /*
    * Function used to validate conditions in case the contract is called with incorrect data
    */
    function() payable isFundable external {
      if(now > salePeriod) throw;
      if(block.number < fundingStartBlock) throw;
      if(block.number > fundingStopBlock) throw;
      if(totalUsedTokens >= totalSupply) throw;

      if (msg.value == 0) throw;

      //transfer money to PillarTokenFactory MultisigWallet
      if(!pillarTokenFactory.send(msg.value)) throw;

      uint numTokens = msg.value.div(tokenPrice);
      totalUsedTokens = totalUsedTokens.add(numTokens);
      if (totalUsedTokens > totalSupply) throw;

      balances[msg.sender] = balances[msg.sender].add(numTokens);

      Transfer(0, msg.sender, numTokens);
    }

    /*
    * Function that performs the actual purchase
    */
    function purchase() payable isFundable external {
      if(now > salePeriod) throw;
      if(block.number < fundingStartBlock) throw;
      if(block.number > fundingStopBlock) throw;
      if(totalUsedTokens >= totalSupply) throw;

      if (msg.value == 0) throw;

      //transfer money to PillarTokenFactory MultisigWallet
      if(!pillarTokenFactory.send(msg.value)) throw;

      uint numTokens = msg.value.div(tokenPrice);
      totalUsedTokens = totalUsedTokens.add(numTokens);
      if (totalUsedTokens > totalSupply) throw;

      balances[msg.sender] = balances[msg.sender].add(numTokens);

      Transfer(0, msg.sender, numTokens);
    }

    /*
    * Function to check sale period
    */
    function checkSalePeriod() external constant returns (uint) {
      return salePeriod;
    }

    /*
    * Function that reports whether funding is still active
    */
    function fundingActive() constant isFundable external returns (bool){
      if(block.number < fundingStartBlock || block.number > fundingStopBlock || totalUsedTokens > totalSupply){
        return false;
      }
      return true;
    }

    /*
    * Function that reports the number of tokens left
    */
    function numberOfTokensLeft() constant external returns (uint256) {
      if (block.number > fundingStopBlock) {
        return 0;
      }
      uint tokensAvailableForSale = totalSupply - totalUsedTokens;
      return tokensAvailableForSale;
    }

    /*
    * Function that checks the status of ICO
    */
    function isFinalized() constant external returns (bool){
      return !fundingMode;
    }

    /*
    * Function that finalizes the ICO
    */
    function finalize() isFundable onlyOwner external {
      if ((block.number <= fundingStopBlock ||
        totalUsedTokens < minTokensForSale) &&
        totalUsedTokens < totalSupply) throw;

        // switch funding mode off
        fundingMode = false;

        teamAllocation = new TeamAllocation();

        balances[address(teamAllocation)] = teamAllocationTokens;
        //transfer any balance available to Pillar Multisig Wallet
        if (!pillarTokenFactory.send(this.balance)) throw;

    }

    function refund() isFundable external {
      if(block.number <= fundingStopBlock) throw;
      if(totalUsedTokens >= minTokensForSale) throw;

      uint plrValue = balances[msg.sender];
      if(plrValue == 0) throw;

      balances[msg.sender] = 0;

      uint ethValue = plrValue.mul(tokenPrice);
      if(!msg.sender.send(ethValue)) throw;
      Refund(msg.sender, ethValue);
    }

    /*
    * Function used to allocate tokens to an address.
    * This will be used for team allocation and presale.
    */
    function allocateTokens(address _to,uint _tokens) isNotFundable onlyOwner external {
      if (!fundingMode) throw;

      if ((block.number <= fundingStopBlock ||
        totalUsedTokens < minTokensForSale) &&
        totalUsedTokens < totalSupply) throw;

      totalUsedTokens = totalUsedTokens.sub(_tokens);
      balances[_to] = balances[_to].add(_tokens);
    }
}
