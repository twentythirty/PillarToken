pragma solidity ^0.4.11;

import './TestWallet.sol';
import './zeppelin/SafeMath.sol';

contract IcedStorage is TestWallet {
  using SafeMath for uint;

  uint lockPeriod;

  function IcedStorage(address[] _owners,uint _required,uint _lock)
  PillarTokenFactory(_owners, _required){
    if(_lock == 3) {
      lockPeriod = now.add(3 years);
    } else {
      lockPeriod = now.add(10 years);
    }

  }

  function isConfirmed(bytes32 transactionHash) public constant returns (bool) {
    if(!isLocked()) {
      uint count = 0;
      for (uint i=0; i<owners.length; i++) {
        if (confirmations[transactionHash][owners[i]]) {
          count += 1;
        }
        if (count == required) {
          return true;
        }
      }
    }
  }

  function isLocked() returns (bool){
    if(now > lockPeriod) {
      return true;
    }
    return false;
  }
 }
