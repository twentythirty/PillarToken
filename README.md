# Pillar Contracts

## Description:

The pillar ICO is made of three contracts which are ERC20 compliant token built using OpenZeppelin library.  
The naming convention used describs the purpose of the individual contracts.


1) PillarPreSale - in development
2) PillarToken - deployed in kovan test net
3) TeamAllocation - in development

## Dependencies

We use Truffle in order to compile and test the contracts.

It can be installed: npm install -g truffle

For more information visit https://truffle.readthedocs.io/en/latest/

Also running node with active json-rpc is required. For testing puproses we suggest using https://github.com/ethereumjs/testrpc

## Usage

./run_testrpc.sh - run testrpc node with required params

truffle compile - compile all contracts

truffle test - run tests

## Specification 
### PillarToken
  Extends Zeppelin Ownable and StandardToken classes.   
  This class will handle the ICO transaction.

#### Methods 
##### pause() - emergency stop of ICO
 > function pause() onlyOwner external returns (bool) 

#####  payable - validator function
 > function() payable isFundingModeStop external 
 
 ##### purchase - carry out purchase transaction
 > function purchase() payable isFundingModeStop external
 
#####  finalize - end the ICO gracefully
 > finalize() external onlyOwner

#####  refund - 
 > function refund() isFundingModeStop external

#### Events
##### Refund
> event Refund(address indexed _from,uint256 _value);
    
##### Migrate    
> event Migrate(address indexed _from, address indexed _to, uint256 _value);
