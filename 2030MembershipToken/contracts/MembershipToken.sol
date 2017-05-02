pragma solidity ^0.4.10;

import './TeamAllocation.sol';
import './SafeMath.sol';

contract MembershipToken {
    using SafeMath for uint;

    TeamAllocation tAll;

    string  public constant name = "Twenty Thirty Alpha Club Token";

    string  public constant symbol = "TTA";

    uint8  public constant decimals = 18;

    uint256  public constant totaNumberOfToken = 4000000;

    uint256  public constant tokenCreationRate = 50;

    // Minimum token creation
    uint256 public constant tokenCreationMin = 1000000;

    //total token - member token
    uint256  public constant totalTokenOffer = totaNumberOfToken - 600000;

    uint256 public salePeriod;

    uint256 fundingStartBlock;
    uint256 fundingStopBlock;
    // flags whether ICO is afoot.
    bool fundingMode = true;

    //total tokens supply
    uint256 totalTokens;

    mapping (address => uint256) balances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function MembershipToken(){
      //sale peioriod
      salePeriod = now + 16 days;
    }

    function checkSalePeriod() external constant returns (uint256) {
      return salePeriod;
    }

    function totalSupply() external constant returns (uint256) {
      return totalTokens;
    }

    function balanceOf(address owner) external constant returns (uint256) {
      return balances[owner];
    }

    // ICO
    function fundingActive() constant external returns (bool){
      if(!fundingMode) return false;

      if(block.number < fundingStartBlock || block.number > fundingStopBlock || totalTokenOffer >= tokenCreationMin){
        return false;
      }
      return true;
    }

    function numberOfTokensLeft() constant external returns (uint256) {
      if (!fundingMode) return 0;
      if (block.number > fundingStopBlock) {
        return 0;
      }
      return totalTokenOffer - totalTokens;
    }

    function finalized() constant external returns (bool){
      return !fundingMode;
    }

    function() payable external {
      if(!fundingMode) throw;
      if(block.number < fundingStartBlock) throw;
      if(block.number > fundingStopBlock) throw;
      if(totalTokens >= totalTokenOffer) throw;

      if (msg.value == 0) throw;

      var numTokens = msg.value * tokenCreationRate;
      totalTokens += numTokens;
      if (totalTokens > totalTokenOffer) throw;

      // Assign new tokens to sender
      balances[msg.sender] += numTokens;

      // log token creation event
      Transfer(0, msg.sender, numTokens);
    }

    function finalize() external {
      // continue from here
    }

}


/*
Token Name: Twenty Thirty Alpha Club Token
Abbreviation: TTA or TAC or ACT (is there a hard rule on 3 letters for ERC20?)
Total number of tokens issued: 4,000,000 tokens
No. of decimal places per token: 18 I think is normal?
Nominal price per Token: 1 USD (NOTE: We could price it in ether if we want)
Tokens reserved for Team: 600,000
Period Team token is marked locked: 9 months, compulsory OR mark not-able to use for CryptX.


Total Tokens on offer: 3,400,000

Total Token sale period: 16 days

Minimum Token to sell within offer period: 1,000,000

Team tokens are held in treasury marked as team and can be transferred to team members who can a) not move them for 9 months or b) sell them freely
*/
