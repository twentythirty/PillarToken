pragma solidity ^0.4.10;

import './TeamAllocation.sol';
import './ERC20.sol';
import './SafeMath.sol';
import './MigrationAgent.sol';

contract PillarToken {

    using SafeMath for uint;
    string  public constant name = "PILLAR";
    string  public constant symbol = "PLR";
    uint8  public constant decimals = 18;

    address public migrationAgent;
    address public migrationMaster;
    uint256 public totalMigrated;

    TeamAllocation tAll;
    TeamAllocation public lockedAllocation;

    uint256  public constant totaNumberOfToken = 10000000;

    /* Check ETH/USD rate on the day of the ICO */
    /* 1 ETH = 88 USD ; 1/88 in WEI */
    uint256  public constant tokenCreationRate = 11363636363637;

    address public pillarTokenFactory;

    // Minimum token creation
    uint256 public constant tokenCreationMin = 2000000;
    uint256 public constant reservedTokensForAllocation = 3000000;

    //total token offer is thus 7,000,000
    uint256  public constant totalTokenOffer = totaNumberOfToken - reservedTokensForAllocation;

    uint256 public salePeriod;

    uint256 fundingStartBlock;
    uint256 fundingStopBlock;

    // flags whether ICO is afoot.
    bool fundingMode = true;

    //total tokens supply
    uint256 totalTokens;

    mapping (address => uint256) balances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from,uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    function PillarToken(address _pillarTokenFactory, uint256 _fundingStartBlock, uint256 _fundingStopBlock, address _migrationMaster) {

      //sale peioriod
      salePeriod = now + 60 hours;

      pillarTokenFactory = _pillarTokenFactory;
      migrationMaster = _migrationMaster;
      fundingStartBlock = _fundingStartBlock;
      fundingStopBlock = _fundingStopBlock;
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

    function isFinalized() constant external returns (bool){
      return !fundingMode;
    }

    function() payable external {
      if(!fundingMode) throw;
      if(now > salePeriod) throw;
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
      if (!fundingMode) throw;
      if ((block.number <= fundingStopBlock ||
        totalTokens < tokenCreationMin) &&
        totalTokens < totalTokenOffer) throw;

        // switch funding mode off
        fundingMode = false;

        if (!pillarTokenFactory.send(this.balance)) throw;

        /*uint256 percentOfTotal = */
        totalTokens += reservedTokensForAllocation;
        balances[lockedAllocation] += reservedTokensForAllocation;
        Transfer(0, lockedAllocation, reservedTokensForAllocation);
    }

    function refund() external {

      if(!fundingMode) throw;
      if(block.number <= fundingStopBlock) throw;
      if(totalTokens >= tokenCreationMin) throw;

      var ttaValue= balances[msg.sender];
      if(ttaValue == 0) throw;

      balances[msg.sender] = 0;

      totalTokens -= ttaValue;

      var ethValue = ttaValue / tokenCreationRate;
      if(!msg.sender.send(ethValue)) throw;
      Refund(msg.sender, ethValue);
    }

    function transfer(address _to, uint256 _value) returns (bool) {
        // Abort if not in Operational state.
        if (fundingMode) throw;

        var senderBalance = balances[msg.sender];
        if (senderBalance >= _value && _value > 0) {
            senderBalance -= _value;
            balances[msg.sender] = senderBalance;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    // token migration
    function migrate(uint256 _value) external {
      if (fundingMode) throw;
      if (migrationAgent == 0) throw;

      if (_value == 0) throw;
      if (_value > balances[msg.sender]) throw;

      balances[msg.sender] -= _value;
      totalTokens -= _value;
      totalMigrated += _value;
      MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);

      Migrate(msg.sender, migrationAgent, _value);
    }

    function setMigrationAgent(address _agent) external{
      if(fundingMode) throw;
      if(migrationAgent != migrationAgent) throw;
      if(msg.sender != migrationMaster) throw;
      migrationAgent = _agent;
    }

    function setMigrationMaster(address _master) external {
      if(msg.sender != migrationMaster) throw;
      migrationMaster = _master;
    }
}

/* Check Token.sol here https://github.com/maraoz/golem-crowdfunding/tree/master/contracts

Token Name: Pillar
Abbreviation: PLR
No. of decimal places per token: 18
Total number of tokens issued: 10,000,000 tokens
Tokens on offer for ICO: 7,000,000



Nominal price per Token: 1 USD (to be priced in ether ahead of the event)
Period Team token is marked locked: 9 months
Total Token sale period: 60 hours or until target is reached.
Minimum Token to sell within offer period or return all sent: 2,000,000

Team tokens can either be transferred automatically or a transfer() method would be invoked manually after 12 months.
All Tokens will be tradable as soon as we can get them listed on an exchange - estimate is 2 months from ICO.

Sale Structure
Token sale is terminated:
7,000,000 tokens are sold
60 hours have elapsed from ICO start date

Minimum sale
If tokens sold after 60 hours < 2,000,000,  then:
full refund to all donators


Key
Token sale & ICO have been used interchangeably.


*/
