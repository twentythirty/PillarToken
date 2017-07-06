pragma solidity ^0.4.11;

import './TeamAllocation.sol';
import './UnsoldAllocation.sol';
import './zeppelin/SafeMath.sol';
import './zeppelin/token/StandardToken.sol';
import './zeppelin/ownership/Ownable.sol';
import './zeppelin/lifecycle/Pausable.sol';

/// @title PillarToken - Crowdfunding code for the Pillar Project
/// @author Parthasarathy Ramanujam, Gustavo Guimaraes, Ronak Thacker
contract PillarToken is StandardToken, Ownable {

    using SafeMath for uint;
    string public constant name = "PILLAR";
    string public constant symbol = "PLR";
    uint public constant decimals = 18;

    TeamAllocation teamAllocation;
    UnsoldAllocation unsoldTokens;

    uint constant public minTokensForSale = 3000000 * 10**18;
    uint constant public futureTokens = 120000000 * 10**18;
    uint constant public lockedTeamAllocationTokens = 16000000 * 10**18;
    uint constant public unlockedTeamAllocationTokens = 8000000 * 10**18;
    uint constant public totalAvailableForSale = 560000000 * 10**18;
    address public unlockedTeamStorageVault = 0x4162Ad6EEc341e438eAbe85f52a941B078210819;

    // Funding amount in Finney
    uint public constant tokenPrice  = 1 finney;

    // Multisigwallet where the proceeds will be stored.
    address public pillarTokenFactory;
    // Multisigwallet to unsold tokens
    address public futureSale;

    // Sale Period
    uint public salePeriod;

    uint fundingStartBlock;
    uint fundingStopBlock;

    // flags whether ICO is afoot.
    bool fundingMode;

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
      if(_pillarTokenFactory == address(0)) throw;
      if(_icedWallet == address(0)) throw;
      if(_fundingStopBlock <= _fundingStartBlock) throw;

      salePeriod = now.add(60 hours);
      pillarTokenFactory = _pillarTokenFactory;
      fundingStartBlock = _fundingStartBlock;
      fundingStopBlock = _fundingStopBlock;
      totalUsedTokens = 0;
      totalSupply = 800000000 * 10**18;
      futureSale = _icedWallet;
      //allot 8 million of the 24 million marketing tokens to an address
      balances[unlockedTeamStorageVault] = unlockedTeamAllocationTokens;
      fundingMode = true;
    }

    //@notice Fallback function that accepts the ether and allocates tokens to
    //the msg.sender corresponding to msg.value
    function() payable isFundable external {
      purchase();
    }

    //@notice function that accepts the ether and allocates tokens to
    //the msg.sender corresponding to msg.value
    function purchase() payable isFundable {
      if(now > salePeriod) throw;
      if(block.number < fundingStartBlock) throw;
      if(block.number > fundingStopBlock) throw;
      if(totalUsedTokens >= totalAvailableForSale) throw;

      if (msg.value < tokenPrice) throw;

      uint numTokens = msg.value.div(tokenPrice);
      if(numTokens < 1) throw;
      //transfer money to PillarTokenFactory MultisigWallet
      pillarTokenFactory.transfer(msg.value);

      uint tokens = numTokens * 10**18;
      totalUsedTokens = totalUsedTokens.add(tokens);
      if (totalUsedTokens > totalAvailableForSale) throw;

      balances[msg.sender] = balances[msg.sender].add(tokens);

      //fire the event notifying the transfer of tokens
      Transfer(0, msg.sender, tokens);
    }

    //@notice Function that reports how long the sale is active
    function checkSalePeriod() external constant returns (uint) {
      return salePeriod;
    }

    //@notice Function reports the number of tokens available for sale
    function numberOfTokensLeft() constant returns (uint256) {
      uint tokensAvailableForSale = totalAvailableForSale.sub(totalUsedTokens);
      return tokensAvailableForSale;
    }

    //@notice Finalize the ICO, send team allocation tokens
    //@notice send any remaining balance to the MultisigWallet
    //@notice unsold tokens will be sent to icedwallet
    function finalize() isFundable onlyOwner external {
      if ((block.number <= fundingStopBlock && totalUsedTokens < minTokensForSale)) throw;

      if(futureSale == address(0)) throw;

        // switch funding mode off
        fundingMode = false;

        //Allot team tokens to a smart contract which will frozen for 9 months
        teamAllocation = new TeamAllocation();
        balances[address(teamAllocation)] = lockedTeamAllocationTokens;

        //allocate unsold tokens to iced storage
        uint totalUnSold = numberOfTokensLeft();
        unsoldTokens = new UnsoldAllocation(10,futureSale,totalUnSold);
        balances[address(unsoldTokens)] = totalUnSold;

        //transfer any balance available to Pillar Multisig Wallet
        pillarTokenFactory.transfer(this.balance);
    }

    //@notice Function that can be called by purchasers to refund
    //@notice Used only in case the ICO isn't successful.
    function refund() isFundable external {
      if(block.number <= fundingStopBlock) throw;
      if(totalUsedTokens >= minTokensForSale) throw;

      uint plrValue = balances[msg.sender];
      if(plrValue == 0) throw;

      balances[msg.sender] = 0;

      uint ethValue = plrValue.mul(tokenPrice);
      msg.sender.transfer(ethValue);
      Refund(msg.sender, ethValue);
    }

    //@notice Function used for funding in case of refund.
    //@notice Can be called only by the Owner
    function allocateForRefund() external payable onlyOwner {
      //does nothing just accepts and stores the ether
    }

    //@notice Function to allocate tokens to an user.
    //@param `_to` the address of an user
    //@param `_tokens` number of tokens to be allocated.
    //@notice Can be called only when funding is not active and only by the owner
    function allocateTokens(address _to,uint _tokens) isNotFundable onlyOwner external {
      if (!fundingMode) throw;
      uint numOfTokens = _tokens * 10**18;
      balances[_to] = balances[_to].add(numOfTokens);
    }

    //@notice Function to pause the contract.
    //@notice Can be called only when funding is active and only by the owner
    function pause() onlyOwner isFundable external {
      fundingMode = false;
    }

    //@notice Function to unpause the contract.
    //@notice Can be called only when funding is not active and only by the owner
    function unPause() onlyOwner isNotFundable external {
      fundingMode = true;
    }

    //@notice Function to get the current funding status.
    function fundingStatus() external returns (bool){
      return fundingMode;
    }
}
