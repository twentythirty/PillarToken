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
const ownerOne = '0x413fbdb50fa9fecd05c531a0c852c14b9ef70bd2';
const ownerTwo = '0x84d7096063d4c4c44a0111a081e11ea550e6b0c8';
const ownerThree = '0x8fba2d3c59b086ddbe3a82fdcaceab53db7fadf7';

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
