//var SafeMath = artifacts.require("./SafeMath.sol");
//var MigrationAgent = artifacts.require("./MigrationAgent.sol");
//var ERC20Interface = artifacts.require("./ERC20Interface.sol");
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");

module.exports = function(deployer) {
  //deployer.deploy(SafeMath);
  //deployer.deploy(MigrationAgent);
  //deployer.deploy(ERC20Interface);
  deployer.deploy(TeamAllocation);
  //deployer.link(SafeMath, PillarToken);
  //deployer.deploy(PillarToken);
  deployer.deploy(PillarToken,"0xbf7e3e261b7a1c089858b7cb2a04f04328000d1e",0,964400);
};
