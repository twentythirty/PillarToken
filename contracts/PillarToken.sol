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

    TeamAllocation public teamAllocation;
    UnsoldAllocation public unsoldTokens;
    UnsoldAllocation public twentyThirtyAllocation;
    UnsoldAllocation public futureSaleAllocation;

    uint constant public minTokensForSale  = 32000000e18;

    uint constant public maxPresaleTokens             =  48000000e18;
    uint constant public totalAvailableForSale        = 528000000e18;
    uint constant public futureTokens                 = 120000000e18;
    uint constant public twentyThirtyTokens           =  80000000e18;
    uint constant public lockedTeamAllocationTokens   =  16000000e18;
    uint constant public unlockedTeamAllocationTokens =   8000000e18;

    address public unlockedTeamStorageVault = 0x4162Ad6EEc341e438eAbe85f52a941B078210819;
    address public twentyThirtyVault = 0xe72bA5c6F63Ddd395DF9582800E2821cE5a05D75;
    address public futureSaleVault = 0xf0231160Bd1a2a2D25aed2F11B8360EbF56F6153;
    address unsoldVault;

    //Storage years
    uint constant coldStorageYears = 10;
    uint constant futureStorageYears = 3;

    uint totalPresale = 0;

    // Funding amount in ether
    uint public constant tokenPrice  = 0.0005 ether;

    // Multisigwallet where the proceeds will be stored.
    address public pillarTokenFactory;

    uint fundingStartBlock;
    uint fundingStopBlock;

    // flags whether ICO is afoot.
    bool fundingMode;

    //total used tokens
    uint totalUsedTokens;

    event Refund(address indexed _from,uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event MoneyAddedForRefund(address _from, uint256 _value,uint256 _total);

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
    //@param `_icedWallet` - Multisigwallet address to which unsold tokens are assigned
    function PillarToken(address _pillarTokenFactory, address _icedWallet) {
      if(_pillarTokenFactory == address(0)) throw;
      if(_icedWallet == address(0)) throw;

      pillarTokenFactory = _pillarTokenFactory;
      totalUsedTokens = 0;
      totalSupply = 800000000e18;
      unsoldVault = _icedWallet;

      //allot 8 million of the 24 million marketing tokens to an address
      balances[unlockedTeamStorageVault] = unlockedTeamAllocationTokens;

      //allocate tokens for 2030 wallet locked in for 3 years
      futureSaleAllocation = new UnsoldAllocation(futureStorageYears,futureSaleVault,futureTokens);
      balances[address(futureSaleAllocation)] = futureTokens;

      //allocate tokens for future wallet locked in for 3 years
      twentyThirtyAllocation = new UnsoldAllocation(futureStorageYears,twentyThirtyVault,twentyThirtyTokens);
      balances[address(twentyThirtyAllocation)] = twentyThirtyTokens;

      fundingMode = false;
    }

    //@notice Fallback function that accepts the ether and allocates tokens to
    //the msg.sender corresponding to msg.value
    function() payable isFundable external {
      purchase();
    }

    //@notice function that accepts the ether and allocates tokens to
    //the msg.sender corresponding to msg.value
    function purchase() payable isFundable {
      if(block.number < fundingStartBlock) throw;
      if(block.number > fundingStopBlock) throw;
      if(totalUsedTokens >= totalAvailableForSale) throw;

      if (msg.value < tokenPrice) throw;

      uint numTokens = msg.value.div(tokenPrice);
      if(numTokens < 1) throw;
      //transfer money to PillarTokenFactory MultisigWallet
      pillarTokenFactory.transfer(msg.value);

      uint tokens = numTokens.mul(1e18);
      totalUsedTokens = totalUsedTokens.add(tokens);
      if (totalUsedTokens > totalAvailableForSale) throw;

      balances[msg.sender] = balances[msg.sender].add(tokens);

      //fire the event notifying the transfer of tokens
      Transfer(0, msg.sender, tokens);
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
      if (block.number <= fundingStopBlock) throw;

      if (totalUsedTokens < minTokensForSale) throw;

      if(unsoldVault == address(0)) throw;

      // switch funding mode off
      fundingMode = false;

      //Allot team tokens to a smart contract which will frozen for 9 months
      teamAllocation = new TeamAllocation();
      balances[address(teamAllocation)] = lockedTeamAllocationTokens;

      //allocate unsold tokens to iced storage
      uint totalUnSold = numberOfTokensLeft();
      if(totalUnSold > 0) {
        unsoldTokens = new UnsoldAllocation(coldStorageYears,unsoldVault,totalUnSold);
        balances[address(unsoldTokens)] = totalUnSold;
      }

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

      uint ethValue = plrValue.mul(tokenPrice).div(1e18);
      msg.sender.transfer(ethValue);
      Refund(msg.sender, ethValue);
    }

    //@notice Function used for funding in case of refund.
    //@notice Can be called only by the Owner
    function allocateForRefund() external payable onlyOwner returns (uint){
      //does nothing just accepts and stores the ether
      MoneyAddedForRefund(msg.sender,msg.value,this.balance);
      return this.balance;
    }

    //@notice Function to allocate tokens to an user.
    //@param `_to` the address of an user
    //@param `_tokens` number of tokens to be allocated.
    //@notice Can be called only when funding is not active and only by the owner
    function allocateTokens(address _to,uint _tokens) isNotFundable onlyOwner external {
      uint numOfTokens = _tokens.mul(1e18);
      totalPresale = totalPresale.add(numOfTokens);

      if(totalPresale > maxPresaleTokens) throw;

      balances[_to] = balances[_to].add(numOfTokens);
    }

    //@notice Function to unPause the contract.
    //@notice Can be called only when funding is active and only by the owner
    function unPauseTokenSale() onlyOwner isNotFundable external returns (bool){
      fundingMode = true;
      return fundingMode;
    }

    //@notice Function to pause the contract.
    //@notice Can be called only when funding is active and only by the owner
    function pauseTokenSale() onlyOwner isFundable external returns (bool){
      fundingMode = false;
      return !fundingMode;
    }

    //@notice Function to start the contract.
    //@param `_fundingStartBlock` - block from when ICO commences
    //@param `_fundingStopBlock` - block from when ICO ends.
    //@notice Can be called only when funding is not active and only by the owner
    function startTokenSale(uint _fundingStartBlock, uint _fundingStopBlock) onlyOwner isNotFundable external returns (bool){
      if(_fundingStopBlock <= _fundingStartBlock) throw;

      fundingStartBlock = _fundingStartBlock;
      fundingStopBlock = _fundingStopBlock;
      fundingMode = true;
      return fundingMode;
    }

    //@notice Function to get the current funding status.
    function fundingStatus() external constant returns (bool){
      return fundingMode;
    }
}
