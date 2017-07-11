var SafeMath = artifacts.require('./zeppelin/SafeMath.sol');
var PillarPresale = artifacts.require('./PillarPresale.sol');
var UnsoldAllocation = artifacts.require('./UnsoldAllocation.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");
//var environment = 'live';
//var environment = 'rinkeby';

module.exports = function(deployer) {
/*
  //if(environment == 'rinkeby') {
    //for rinkeby
    const presaleStartBlock = 517460;
    const presaleEndBlock = 518750;
    const presaleMultisigWallet = '0xFa30C312999731297236302B1cE272675223EBF8'; //gnosis
  //}
  */
  //if(environment == 'live') {
    //mainnet
    const presaleStartBlock = 4003791;
    const presaleEndBlock = 4017800;
    const presaleMultisigWallet = '0x9c5254d935cf85bb7bebdd8558d3b11cd27a387d'; //gnosis
  //}
  deployer.deploy(SafeMath);
  deployer.link(SafeMath,UnsoldAllocation);
  deployer.link(SafeMath,PillarPresale);
  deployer.link(SafeMath,TeamAllocation);
  deployer.link(SafeMath,PillarToken);
  //deployer.deploy(UnsoldAllocation,10,multiSigWallet,100);
  deployer.deploy(PillarPresale,presaleMultisigWallet,presaleStartBlock,presaleEndBlock);
  //deployer.deploy(TeamAllocation);
  //deployer.deploy(PillarToken,multiSigWallet,icoStartBlock,icoEndBlock,tenYearIcedStorage);
};
