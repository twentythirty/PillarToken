//var SafeMath = artifacts.require("./SafeMath.sol");
//var MigrationAgent = artifacts.require("./MigrationAgent.sol");
//var ERC20Interface = artifacts.require("./ERC20Interface.sol");
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");

module.exports = function(deployer) {
  //deployer.deploy(TeamAllocation);
  //deployer.deploy(PillarToken,"0x00e4A3C02834F7d443011Fd0546566EF9814982b",1741595,1841595);
  deployer.deploy(PillarToken,"0x7aef2497193aca16a7cda630164f0b8c28a17800",0,1000000);
};
