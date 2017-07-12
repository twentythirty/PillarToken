var SafeMath = artifacts.require('./zeppelin/SafeMath.sol');
var PillarPresale = artifacts.require('./PillarPresale.sol');
var UnsoldAllocation = artifacts.require('./UnsoldAllocation.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");

module.exports = function(deployer) {
 //mainnet
  const presaleStartBlock = 4011019;
  const presaleEndBlock = 4021963;
  const presaleMultisigWallet = '0x9c5254d935cf85bb7bebdd8558d3b11cd27a387d'; 

  deployer.deploy(SafeMath);
  deployer.link(SafeMath,PillarPresale);
  deployer.deploy(PillarPresale,presaleMultisigWallet,presaleStartBlock,presaleEndBlock);
};
