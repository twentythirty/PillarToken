var SafeMath = artifacts.require('./zeppelin/SafeMath.sol');
var PillarPresale = artifacts.require('./PillarPresale.sol');
var UnsoldAllocation = artifacts.require('./UnsoldAllocation.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");
//for testrpc
/*
const presaleStartBlock = 0;
const presaleEndBlock = 100;
const icoStartBlock = 0;
const icoEndBlock = 10000;
*/
//for rinkeby
const presaleStartBlock = 509990;
const presaleEndBlock = 515750;
//const icoStartBlock = 515750;
//const icoEndBlock = 510000;
//
//const multiSigWallet = '0xa4ba560bAFC35a2B3aD5A380fF162e6Cb95aCe6F' //local
const multiSigWallet = '0x64f267849723ea828cb47d59f38ec1ea06940106'; //gnosis
//const tenYearIcedStorage = '0x50402a9c6b7561346421de274d8526f9216e3899'; //gnosis
module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath,UnsoldAllocation);
  deployer.link(SafeMath,PillarPresale);
  deployer.link(SafeMath,TeamAllocation);
  deployer.link(SafeMath,PillarToken);
  deployer.deploy(UnsoldAllocation,10,multiSigWallet,100);
  deployer.deploy(PillarPresale,multiSigWallet,presaleStartBlock,presaleEndBlock);
  //deployer.deploy(TeamAllocation);
  //deployer.deploy(PillarToken,multiSigWallet,icoStartBlock,icoEndBlock,tenYearIcedStorage);
};
