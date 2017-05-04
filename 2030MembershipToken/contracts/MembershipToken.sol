pragma solidity ^0.4.10;

import './TeamAllocation.sol';
import './ICOFunded.sol';
import './SafeMath.sol';
import './MigrationAgent.sol';

contract MembershipToken is ICOFunded {
    using SafeMath for uint;
    string  public constant name = "Twenty Thirty Alpha Club Token";
    string  public constant symbol = "TTA";
    uint8  public constant decimals = 18;

    address public migrationAgent;
    address public migrationMaster;
    uint256 public totalMigrated;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);

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

/* End point*/
/*Check Token.sol here https://github.com/maraoz/golem-crowdfunding/tree/master/contracts

Check construction function in MembershipToken.sol. There may be variables missing there.
*/

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
