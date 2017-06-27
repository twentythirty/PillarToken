pragma solidity ^0.4.11;

import './zeppelin/SafeMath.sol';
import './zeppelin/ownership/Ownable.sol';
import './zeppelin/lifecycle/Pausable.sol';
import './PillarToken.sol';
import './UnsoldAllocation.sol';

contract PillarPresale is Pausable {
  using SafeMath for uint;
  uint constant presaleSupply = 16000000;

  address pillarTokenFactory;
  uint totalUsedTokens;
  mapping(address => uint) balances;
  //Sale Period
  address[] purchasers;
  uint public salePeriod;

  uint startBlock;
  uint endBlock;

  // flags whether ICO is afoot.
  bool fundingMode = true;

  //price will be in finney
  uint constant PRESALE_PRICE = 1 finney;

  address icingWallet;
  UnsoldAllocation unsoldPresale;

  modifier isFundable() {
      if (!fundingMode) throw;
      _;
  }

  function PillarPresale(address _pillarTokenFactory,uint _startBlock,uint _endBlock) {
    //presale is open for
    salePeriod = now.add(60 hours);
    startBlock = _startBlock;
    endBlock = _endBlock;
    pillarTokenFactory = _pillarTokenFactory;
    totalUsedTokens = 0;
  }

  function () external isFundable payable {
    if(now > salePeriod) throw;
    if(block.number < startBlock) throw;
    if(block.number > endBlock) throw;
    if(totalUsedTokens >= presaleSupply) throw;
    if(msg.value == 0) throw;

    uint numTokens = msg.value.div(PRESALE_PRICE);
    totalUsedTokens = totalUsedTokens.add(numTokens);
    if (totalUsedTokens > presaleSupply) throw;

    //transfer money to PillarTokenFactory MultisigWallet
    if(!pillarTokenFactory.send(msg.value)) throw;

    purchasers.push(msg.sender);
    balances[msg.sender] = balances[msg.sender].add(numTokens);
  }

  function getPresaleSupply() external constant returns (uint256) {
    return presaleSupply;
  }

  //@notice Function reports the number of tokens available for sale
  function numberOfTokensLeft() constant returns (uint256) {
    uint tokensAvailableForSale = presaleSupply.sub(totalUsedTokens);
    return tokensAvailableForSale;
  }

  function finalize() external onlyOwner {
    if(!fundingMode) throw;

    if((block.number <= startBlock || block.number >= endBlock)) throw;

    if(icingWallet == address(0)) throw;

    unsoldPresale = new UnsoldAllocation(3,icingWallet,numberOfTokensLeft());
    //migrate the ether to the pillarTokenFactory wallet
    if(!pillarTokenFactory.send(this.balance)) throw;

  }

  function balanceOf(address owner) returns (uint) {
    return balances[owner];
  }

  function getPurchasers() external returns (address[]) {
    return purchasers;
  }

  function numOfPurchasers() external returns (uint) {
    return purchasers.length;
  }

  function setIcingWallet(address _icingWalletAddress) external {
    icingWallet = _icingWalletAddress;
  }
}
