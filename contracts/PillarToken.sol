pragma solidity ^0.4.11;

import './TeamAllocation.sol';
import './zeppelin/SafeMath.sol';
import './zeppelin/token/StandardToken.sol';
import './zeppelin/ownership/Ownable.sol';

/// @title PillarToken - Crowdfunding code for the Pillar Project
/// @author Parthasarathy Ramanujam, Gustavo Guimaraes, Ronak Thacker
contract PillarToken is StandardToken, Ownable {

    using SafeMath for uint;
    string public constant name = "PILLAR";
    string public constant symbol = "PLR";
    uint public constant decimals = 18;

    address public futureSale;
    TeamAllocation teamAllocation;

    uint constant public minTokensForSale = 3000000;
    uint constant public totalAllocationTokens = 24000000;
    uint constant public futureTokens = 120000000;
    uint constant public teamAllocationTokens = 24000000;
    uint constant public totalAvailableForSale = 560000000;

    // Funding amount in Finney
    uint public constant tokenPrice  = 1 finney;

    // Multisigwallet where the proceeds will be stored.
    address public pillarTokenFactory;

    // Sale Period
    uint public salePeriod;

    uint fundingStartBlock;
    uint fundingStopBlock;

    // flags whether ICO is afoot.
    bool fundingMode = true;

    //total used tokens
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

    //@notice  Constructor of PillarToken
    //@param `_pillarTokenFactory` - multisigwallet address to store proceeds.
    //@param `_fundingStartBlock` - block from when ICO commences
    //@param `_fundingStopBlock` - block from when ICO ends.
    //@param `_icedWallet` - Multisigwallet address to which unsold tokens are assigned
    function PillarToken(address _pillarTokenFactory, uint256 _fundingStartBlock, uint256 _fundingStopBlock, address _icedWallet) {
      salePeriod = now.add(60 hours);
      pillarTokenFactory = _pillarTokenFactory;
      fundingStartBlock = _fundingStartBlock;
      fundingStopBlock = _fundingStopBlock;
      totalUsedTokens = 0;
      totalSupply = 800000000;
      futureSale = _icedWallet;
    }

    //@notice Used to pause the contract for firefighting if any.
    //@notice can be called only when the contract is fundable
    function pause() onlyOwner isFundable external returns (bool) {
      fundingMode = false;
    }

    //@notice Fallback function that accepts the ether and allocates tokens to
    //the msg.sender corresponding to msg.value
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

    //@notice function that accepts the ether and allocates tokens to
    //the msg.sender corresponding to msg.value
    function purchase() payable isFundable external {
      if(now > salePeriod) throw;
      if(block.number < fundingStartBlock) throw;
      if(block.number > fundingStopBlock) throw;
      if(totalUsedTokens >= totalAvailableForSale) throw;

      if (msg.value == 0) throw;

      //transfer money to PillarTokenFactory MultisigWallet
      if(!pillarTokenFactory.send(msg.value)) throw;

      uint numTokens = msg.value.div(tokenPrice);
      totalUsedTokens = totalUsedTokens.add(numTokens);
      if (totalUsedTokens > totalAvailableForSale) throw;

      balances[msg.sender] = balances[msg.sender].add(numTokens);

      Transfer(0, msg.sender, numTokens);
    }

    //@notice Function that reports how long the sale is active
    function checkSalePeriod() external constant returns (uint) {
      return salePeriod;
    }

    //@notice Function that reports whether funding is active.
    function fundingActive() constant isFundable external returns (bool){
      if(block.number < fundingStartBlock || block.number > fundingStopBlock || totalUsedTokens > totalAvailableForSale){
        return false;
      }
      return true;
    }

    //@notice Function reports the number of tokens available for sale
    function numberOfTokensLeft() constant returns (uint256) {
      if (block.number > fundingStopBlock) {
        return 0;
      }
      uint tokensAvailableForSale = totalAvailableForSale - totalUsedTokens;
      return tokensAvailableForSale;
    }

    //@notice Finalize the ICO, send team allocation tokens
    //@notice send any remaining balance to the MultisigWallet
    //@notice unsold tokens will be sent to icedwallet
    function finalize() isFundable onlyOwner external {
      if ((block.number <= fundingStopBlock ||
        totalUsedTokens < minTokensForSale) &&
        totalUsedTokens < totalAvailableForSale) throw;

        // switch funding mode off
        fundingMode = false;

        teamAllocation = new TeamAllocation();

        balances[address(teamAllocation)] = teamAllocationTokens;
        //allocate unsold tokens to iced storage
        balances[futureSale] = numberOfTokensLeft();
        //transfer any balance available to Pillar Multisig Wallet
        if (!pillarTokenFactory.send(this.balance)) throw;
    }

    //@notice Function that can be called by purchasers to refund
    //@notice Used only in case the function isn't successful.
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

    //@notice Function used for funding in case of refund.
    //@notice Can be called only by the Owner
    function allocateForRefund() external onlyOwner {
      //does nothing just accepts and stores the ether
    }

    //@notice Function to allocate tokens to an user.
    //@param `_to` the address of an user
    //@param `_tokens` number of tokens to be allocated.
    //@notice Can be called only when funding is not active and only by the owner
    function allocateTokens(address _to,uint _tokens) isNotFundable onlyOwner external {
      if (!fundingMode) throw;

      totalUsedTokens = totalUsedTokens.sub(_tokens);
      balances[_to] = balances[_to].add(_tokens);
    }
}
