var SafeMath = artifacts.require('./zeppelin/SafeMath.sol');
var PillarPresale = artifacts.require('./PillarPresale.sol');
var UnsoldAllocation = artifacts.require('./UnsoldAllocation.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");
//var Token = artifacts.require("./Token.sol");

//for testrpc
const presaleStartBlock = 0;
const presaleEndBlock = 1000;
const icoStartBlock = 0;
const icoEndBlock = 10000000;
/*
//for rinkeby
const presaleStartBlock = 448440;
const presaleEndBlock = 449440;
const icoStartBlock = 449441;
const icoEndBlock = 600000;
/*
//for kovan
const presaleStartBlock = 2323400;
const presaleEndBlock = 2340000;
const icoStartBlock = 2340001;
const icoEndBlock = 2360000;

//for ropsten
const presaleStartBlock = 1200000;
const presaleEndBlock = 1205000;
const icoStartBlock = 1205001;
const icoEndBlock = 1300000;
*/
//
//const multiSigWallet = '0xa4ba560bAFC35a2B3aD5A380fF162e6Cb95aCe6F' //local
const multiSigWallet = '0x9291350ac679657c97c8f059077fd5574ac7ecc6'; //gnosis
const threeYearIcedStorage = '0x50402a9c6b7561346421de274d8526f9216e3899'; //gnosis
const tenYearIcedStorage = '0x50402a9c6b7561346421de274d8526f9216e3899'; //gnosis
/*
const multiSigWallet = '0xa52120b2465eb332e8820a1326bc158258a629c4'
const threeYearIcedStorage = '0x5c28f2b9ca03302b18696ab27c641bbea75d73f1';
const tenYearIcedStorage = '0x5c28f2b9ca03302b18696ab27c641bbea75d73f1';
*/
module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  //deployer.deploy(Token,multiSigWallet,icoStartBlock,icoEndBlock,tenYearIcedStorage);
  deployer.link(SafeMath,UnsoldAllocation);
  deployer.link(SafeMath,PillarPresale);
  deployer.link(SafeMath,TeamAllocation);
  deployer.link(SafeMath,PillarToken);
  deployer.deploy(UnsoldAllocation,10,multiSigWallet,100);
  deployer.deploy(PillarPresale,multiSigWallet,presaleStartBlock,presaleEndBlock);
  deployer.deploy(TeamAllocation);
  deployer.deploy(PillarToken,multiSigWallet,icoStartBlock,icoEndBlock,tenYearIcedStorage);
};
