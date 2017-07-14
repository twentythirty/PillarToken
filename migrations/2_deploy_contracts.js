var SafeMath = artifacts.require('./zeppelin/SafeMath.sol');
var PillarPresale = artifacts.require('./PillarPresale.sol');
var UnsoldAllocation = artifacts.require('./UnsoldAllocation.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");

module.exports = function(deployer) {
 //mainnet
  const tokenMultisigWallet = '0x05a9afd79a05c3e1afefa282ef8d58f9366b160b';
  const icedWallet = '0xff678a624472fe0d195e3cac47dec2375dc2d8be';

  deployer.deploy(SafeMath);
  //deployer.link(SafeMath,PillarPresale);
  //deployer.deploy(PillarPresale,presaleMultisigWallet,presaleStartBlock,presaleEndBlock);
  deployer.link(SafeMath,UnsoldAllocation);
  deployer.link(SafeMath,TeamAllocation);
  deployer.link(SafeMath,PillarToken);
  deployer.deploy(PillarToken,tokenMultisigWallet,icedWallet);
};
