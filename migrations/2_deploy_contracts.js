//var SafeMath = artifacts.require("./SafeMath.sol");
//var MigrationAgent = artifacts.require("./MigrationAgent.sol");
//var ERC20Interface = artifacts.require("./ERC20Interface.sol");
var TestWallet = artifacts.require('./TestWallet.sol');
var Iced3Storage = artifacts.require('./IcedStorage.sol');
var Iced10Storage = artifacts.require('./IcedStorage.sol');
var PillarPresale = artifacts.require('./PillarPresale.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");
const presaleStartBlock = 0;
const presaleEndBlock = 1000;
const icoStartBlock = 0;
const icoEndBlock = 10000000;
const ownerOne = '0x97e3264d86cdc198b663c6cd0636e94ad4ea3357';
const ownerTwo = '0x30053504db7d22311c8b238f87d1552b1d6427ac';
const ownerThree = '0x28f387a5524a79ea7c3e4f3abdf03de771ae72bf';

module.exports = function(deployer) {

  const owners = [ownerOne,ownerTwo,ownerThree];
  const requiredApproval = 3;

  deployer.deploy(TestWallet,owners,requiredApproval);

  deployer.deploy(Iced3Storage,owners,requiredApproval,3);
  deployer.deploy(PillarPresale,presaleStartBlock,presaleEndBlock,TestWallet.address);

  deployer.deploy(Iced10Storage,owners,requiredApproval,10);
  deployer.deploy(TeamAllocation);
  deployer.deploy(PillarToken,TestWallet.address,icoStartBlock,icoEndBlock,Iced10Storage.address);

};
