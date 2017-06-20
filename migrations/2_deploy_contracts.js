//var SafeMath = artifacts.require("./SafeMath.sol");
//var MigrationAgent = artifacts.require("./MigrationAgent.sol");
//var ERC20Interface = artifacts.require("./ERC20Interface.sol");
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

module.exports = async function(deployer) {

  const owners = [accounts[1],accounts[2],accounts[3]];
  const requiredApproval = 2;
  const dailyLimit = 0;
  var plrTokenFactory = await deployer.deploy(PillarTokenFactory,owners,requiredApproval,dailyLimit);

  deployer.deploy(Iced3Storage,owners,requiredApproval,dailyLimit,3);
  deployer.link(PillarPresale,Iced3Storage);
  deployer.deploy(PillarPresale,presaleStartBlock,presaleEndBlock,plrTokenFactory.address);

  deployer.deploy(Iced10Storage,owners,requiredApproval,dailyLimit,10);
  deployer.deploy(TeamAllocation);
  deployer.link(PillarToken,[Iced10Storage,TeamAllocation]);
  deployer.deploy(PillarToken,plrTokenFactory.address,icoStartBlock,icoEndBlock);
};
