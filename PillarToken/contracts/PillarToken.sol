pragma solidity ^0.4.8;

import './TeamAllocation.sol';
import './ERC20Interface.sol';
import './MigrationAgent.sol';
import './Ownable.sol';
import './SafeMath.sol';

contract PillarToken is ERC20Interface, Ownable {

    using SafeMath for uint;
    string public constant name = "PILLAR";
    string public constant symbol = "PLR";
    //uint8 costs more gas than uint246/uint so changed the data type
    uint public constant decimals = 18;

    address public migrationAgent;
    address public migrationMaster;
    uint public totalMigrated;

    TeamAllocation tAll;
    TeamAllocation public lockedAllocation;

    uint  public constant totalNumberOfTokens = 10000000;

    /* Check ETH/USD rate on the day of the ICO */
    /* 1 ETH = 88 USD ; 1/88 of USD expressed in WEI */
    // Need to revisit this value at later point
    uint public constant tokenPrice  = 11363636363637 wei;

    //address corresponding to the pillar token factory where the fund raised will be held.
    address public pillarTokenFactory;

    // Minimum token creation
    uint public constant minTokensForSale = 2000000;

    // Refactor this to be only one number
    //tokens reserved for team.
    uint public constant totalAllocationTokens = 3000000;

    //total tokens available for sale
    uint public constant tokensAvailableForSale = totalNumberOfTokens.sub(totalAllocationTokens);
    //Sale Period
    uint public salePeriod;

    uint fundingStartBlock;
    uint fundingStopBlock;

    // flags whether ICO is afoot.
    bool fundingMode = true;

    //total used tokens
    uint totalUsedTokens;

    mapping (address => uint256) balances;

    //Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    //event Approval(address indexed _owner, address indexed _spender,uint _value);
    //event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from,uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    modifier isFundingModeStart() {
        if (fundingMode) throw;
        _;
    }

    modifier isFundingModeStop() {
        if (!fundingMode) throw;
        _;
    }

    function PillarToken(address _pillarTokenFactory, uint256 _fundingStartBlock, uint256 _fundingStopBlock, address _migrationMaster) {

      //sale peioriod
      salePeriod = now.add(60 hours);

      pillarTokenFactory = _pillarTokenFactory;
      migrationMaster = _migrationMaster;
      fundingStartBlock = _fundingStartBlock;
      fundingStopBlock = _fundingStopBlock;
      totalUsedTokens = 0;
    }

    /*
    * Function used to validate conditions in case the contract is called with incorrect data
    */
    function() payable isFundingModeStop external {
//      if(!fundingMode) throw;
      if(now > salePeriod) throw;
      if(block.number < fundingStartBlock) throw;
      if(block.number > fundingStopBlock) throw;
      if(totalUsedTokens >= tokensAvailableForSale) throw;

      if (msg.value == 0) throw;

      //total tokens purchased is received gas/cost of 1 token
      uint numTokens = msg.value.div(tokenPrice);
      totalUsedTokens = totalUsedTokens.add(numTokens);
      if (totalUsedTokens > tokensAvailableForSale) throw;

      // Assign new tokens to sender
      balances[msg.sender] = balances[msg.sender].add(numTokens);
      // log token creation event
      Transfer(0, msg.sender, numTokens);
    }

    function checkSalePeriod() external constant returns (uint) {
      return salePeriod;
    }

    function totalSupply() constant returns (uint totalSupply) {
      //return totalTokens;
      totalSupply = tokensAvailableForSale;
    }

    function balanceOf(address owner) constant returns (uint balance) {
      //return balances[owner];
      balance = balances[owner];
    }

    // ICO
    function fundingActive() constant isFundingModeStop external returns (bool){
//      if(!fundingMode) return false;

      //Shouldn't this be total tokensAvailableForSale? Earlier the check was against minTokensForSale
      if(block.number < fundingStartBlock || block.number > fundingStopBlock || totalUsedTokens > tokensAvailableForSale){
        return false;
      }
      return true;
    }

    function numberOfTokensLeft() isFundingModeStop constant external returns (uint256) {
//      if (!fundingMode) return 0;
      if (block.number > fundingStopBlock) {
        return 0;
      }
      return tokensAvailableForSale.sub(totalUsedTokens);
    }

    function isFinalized() constant external returns (bool){
      return !fundingMode;
    }


    function finalize() isFundingModeStop onlyOwner external {
//      if (!fundingMode) throw;

      if ((block.number <= fundingStopBlock ||
        totalUsedTokens < minTokensForSale) &&
        totalUsedTokens < tokensAvailableForSale) throw;

        // switch funding mode off
        fundingMode = false;

        if (!pillarTokenFactory.send(this.balance)) throw;

        /*uint256 percentOfTotal = */
        // Shouldn't this reflect all of the remaining tokens and not just the 300,000?
        totalUsedTokens = totalUsedTokens.add(totalAllocationTokens);
        balances[lockedAllocation] = balances[lockedAllocation].add(totalAllocationTokens);
        Transfer(0, lockedAllocation, totalAllocationTokens);
    }

    function refund() isFundingModeStop external {

//      if(!fundingMode) throw;
      if(block.number <= fundingStopBlock) throw;
      if(totalUsedTokens >= minTokensForSale) throw;

      uint plrValue = balances[msg.sender];
      if(plrValue == 0) throw;

      balances[msg.sender] = 0;

      totalUsedTokens = totalUsedTokens.sub(plrValue);

      uint ethValue = plrValue.div(tokenPrice);
      if(!msg.sender.send(ethValue)) throw;
      Refund(msg.sender, ethValue);
    }


    function transfer(address _to, uint256 _value) isFundingModeStart returns (bool) {
        // Abort if not in Operational state.
//        if (fundingMode) throw;

        uint senderBalance = balances[msg.sender];
        if (senderBalance >= _value && _value > 0) {
            senderBalance = senderBalance.sub(_value);
            balances[msg.sender] = senderBalance;
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    //transferFrom function to make the token ERC20 complaint
    function transferFrom(address _from, address _to, uint _amount) returns (bool success) {
      if(balances[_from] >= _amount
        && allowed[_from][msg.sender] >= _amount
        && _amount > 0
        && balances[_to].add(_amount) > balances[_to]) {
          balances[_from] = balances[_from].sub(_amount);
          allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
          balances[_to] = balances[_to].add(_amount);
          Transfer(_from, _to, _amount);
          return true;
        } else {
          return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) returns (bool success) {
      allowed[msg.sender][_spender] = _amount;
      Approval(msg.sender, _spender, _amount);
      return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining) {
      return allowed[_owner][_spender];
    }
    // token migration
    function migrate(uint256 _value) isFundingModeStart external {
//      if (fundingMode) throw;
      if (migrationAgent == 0) throw;

      if (_value == 0) throw;
      if (_value > balances[msg.sender]) throw;

      balances[msg.sender] = balances[msg.sender].sub(_value);
      totalUsedTokens = totalUsedTokens.sub(_value);
      totalMigrated = totalMigrated.add(_value);
      MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);

      Migrate(msg.sender, migrationAgent, _value);
    }

    function allocateTokens(address _to,uint _tokens) onlyOwner external {
      if (!fundingMode) throw;

      if ((block.number <= fundingStopBlock ||
        totalUsedTokens < minTokensForSale) &&
        totalUsedTokens < tokensAvailableForSale &&
        (totalUsedTokens - _tokens) < 0) throw;

      totalUsedTokens -= _tokens;
      balances[_to] += _tokens;
    }

    function setMigrationAgent(address _agent) isFundingModeStart external{
//      if(fundingMode) throw;
      if(migrationAgent != migrationAgent) throw;
      if(msg.sender != migrationMaster) throw;
      migrationAgent = _agent;
    }

    function setMigrationMaster(address _master) external {
      if(msg.sender != migrationMaster) throw;
      migrationMaster = _master;
    }

    /* As per the discussion with David in todays ICO call, there is a requirement for two new methods
    * that will allow David, Michael etc to transfer token to different ethereum wallets
    * for donations received through fiat or non crypto currencies
    */
}

/*

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
