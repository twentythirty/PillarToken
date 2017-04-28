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
    
    //total token - member token 
    uint256  public constant totalTokenOffer = totaNumberOfToken - 600000;
    
    uint256 public salePeriod;

    function MembershipToken() {
            // sale period 
            salePeriod = now + 16 days;
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

// Continue from here down
Minimum Token to sell within offer period: 1,000,000
Team tokens are held in treasury marked as team and can be transferred to team members who can a) not move them for 9 months or b) sell them freely
*/
