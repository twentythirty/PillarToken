pragma solidity ^0.4.11;

import './zeppelin/SafeMath.sol';
import './zeppelin/ownership/Ownable.sol';
import './PillarToken.sol';
import './PresaleIcedWallet.sol';

contract PillarPresale is Ownable {
  using SafeMath for uint;
  uint public constant totalSupply = 16000000;
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

  uint constant PRESALE_PRICE = 2857142857000 wei;

  PillarToken public plr;
  PresaleIcedWallet public plWallet;

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

  /**
  * Function to pause the ICO. Will be used for fire fighting
  */
  function pause() onlyOwner external returns (bool) {
    fundingMode = false;
  }


  function () external isFundable payable {
    if(now > salePeriod) throw;
    if(block.number < startBlock) throw;
    if(block.number > endBlock) throw;
    if(totalUsedTokens >= totalSupply) throw;
    if(msg.value == 0) throw;

    uint numTokens = msg.value.div(PRESALE_PRICE);
    totalUsedTokens = totalUsedTokens.add(numTokens);
    if (totalUsedTokens > totalSupply) throw;

    purchasers.push(msg.sender);
    balances[msg.sender] = balances[msg.sender].add(numTokens);
  }

  function finalize() external onlyOwner {
    if(!fundingMode) throw;

    if((block.number <= startBlock || block.number >= endBlock)) throw;

    if(address(plWallet) == address(0)) throw;

    if(address(plr) == address(0)) throw;

    //migrate the ether to the pillarTokenFactory wallet
    if(!pillarTokenFactory.send(this.balance)) throw;

    //move the unsold tokens to a multisig wallet
    uint remain = totalSupply.sub(totalUsedTokens);
    if(remain > 0) {
      plr.allocateTokens(address(plWallet),remain);
    }

    /*
    for(uint i = 0;i<purchasers.length;i++) {
      plr.assignTokens(purchasers[i],balances[purchasers[i]]);
    }
    */
  }

  function balanceOf(address owner) returns (uint) {
    return balances[owner];
  }

  function getPurchasers() external returns (address[]) {
    return purchasers;
  }
}
