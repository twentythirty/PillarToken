var SafeMath = artifacts.require('./zeppelin/SafeMath.sol');
var PillarPresale = artifacts.require('./PillarPresale.sol');
var UnsoldAllocation = artifacts.require('./UnsoldAllocation.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");
var environment = 'live';

if(environment == 'rinkeby') {}
  //for rinkeby
  const presaleStartBlock = 509990;
  const presaleEndBlock = 515750;
  const icoStartBlock = 515750;
  const icoEndBlock = 510000;
}
if(environment == 'live') {
  //mainnet
  const presaleStartBlock = 4003791;
  const presaleEndBlock = 4017800;
  //const icoStartBlock = 515750;
  //const icoEndBlock = 510000;
  const presaleMultisigWallet = '0x9c5254d935cf85bb7bebdd8558d3b11cd27a387d'; //gnosis
}

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath,UnsoldAllocation);
  deployer.link(SafeMath,PillarPresale);
  deployer.link(SafeMath,TeamAllocation);
  deployer.link(SafeMath,PillarToken);
  //deployer.deploy(UnsoldAllocation,10,multiSigWallet,100);
  deployer.deploy(PillarPresale,multiSigWallet,presaleStartBlock,presaleEndBlock);
  //deployer.deploy(TeamAllocation);
  //deployer.deploy(PillarToken,multiSigWallet,icoStartBlock,icoEndBlock,tenYearIcedStorage);
};
