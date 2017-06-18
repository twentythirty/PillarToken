//var SafeMath = artifacts.require("./SafeMath.sol");
//var MigrationAgent = artifacts.require("./MigrationAgent.sol");
//var ERC20Interface = artifacts.require("./ERC20Interface.sol");
var PillarTokenFactory = artifacts.require('./PillarTokenFactory.sol');
var IcedStorage = artifacts.require('./IcedStorage.sol');
var PillarPresale = artifacts.require('./PillarPresale.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");
var presaleStartBlock = 0;
var presaleEndBlock = 1000;
var icoStartBlock = 0;
var icoEndBlock = 10000000;

module.exports = function(deployer) {

  deployer.deploy(PillarTokenFactory,accounts[1],accounts[2],accounts[3]);.then(function() {
    return deployer.deploy(IcedStorage,accounts[1],accounts[2],accounts[3],3);
  }).then(function() {
    return deployer.deploy(PillarPresale,presaleStartBlock,presaleEndBlock,PillarTokenFactory.address);
  }).then(function() {
    return deployer.deploy(IcedStorage,accounts[1],accounts[2],accounts[3],10);
  }).then(function() {
    return deployer.deploy(PillarToken,PillarTokenFactory.address,icoStartBlock,icoEndBlock);
  });
};
