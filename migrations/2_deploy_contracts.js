//var SafeMath = artifacts.require("./SafeMath.sol");
//var MigrationAgent = artifacts.require("./MigrationAgent.sol");
//var ERC20Interface = artifacts.require("./ERC20Interface.sol");
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");

module.exports = function(deployer) {
  //deployer.deploy(TeamAllocation);
  //deployer.deploy(PillarToken,"0x00e4A3C02834F7d443011Fd0546566EF9814982b",1741595,1841595);
  deployer.deploy(PillarToken,"0x91794a21ad86420cb92ca898fac9554a3aa06662",0,1000000);
};
