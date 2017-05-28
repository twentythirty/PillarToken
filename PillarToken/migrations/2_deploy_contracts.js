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
  deployer.deploy(PillarToken,"0x0041Ef310c03a36aA329B3d4f8f04AF8DC06B468",1741595,1841595);
};
