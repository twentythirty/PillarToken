//var SafeMath = artifacts.require("./SafeMath.sol");
//var MigrationAgent = artifacts.require("./MigrationAgent.sol");
//var ERC20Interface = artifacts.require("./ERC20Interface.sol");
var SafeMath = artifacts.require("./zeppelin/SafeMath.sol");
var PillarTokenFactory = artifacts.require('./PillarTokenFactory.sol');
var Iced3Storage = artifacts.require('./IcedStorage.sol');
var Iced10Storage = artifacts.require('./IcedStorage.sol');
var PillarPresale = artifacts.require('./PillarPresale.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");
const presaleStartBlock = 0;
const presaleEndBlock = 1000;
const icoStartBlock = 0;
const icoEndBlock = 10000000;
const ownerOne = '0xb45968c6934bb807fe562c309dfeb894cceaabcd';
const ownerTwo = '0x0c158cef8f6cdbee3ea40dc5f8d5b397902e352c';
const ownerThree = '0xce4ee7de4a08f0f9951f43e04a251f9ef4197d7c';

module.exports = function(deployer) {

  const owners = [ownerOne,ownerTwo,ownerThree];
  const requiredApproval = 2;

  deployer.deploy(PillarTokenFactory,owners,requiredApproval);

  deployer.deploy(Iced3Storage,owners,requiredApproval,3);
  deployer.deploy(PillarPresale,presaleStartBlock,presaleEndBlock,PillarTokenFactory.address);

  deployer.deploy(Iced10Storage,owners,requiredApproval,10);
  deployer.deploy(TeamAllocation);
  deployer.deploy(PillarToken,PillarTokenFactory.address,icoStartBlock,icoEndBlock);

};
