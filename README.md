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
  Extends Zeppelin Ownable class

#### Methods
##### pause() 
 > unction pause() onlyOwner external returns (bool) 

#####  isFundable
 > function () external isFundable payable 
  
#####  finalize
 > finalize() external onlyOwner

#####  balanceOf
 > balanceOf(address owner) returns (uint)

#### Events
