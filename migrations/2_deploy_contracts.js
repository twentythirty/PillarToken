
var PillarPresale = artifacts.require('./PillarPresale.sol');
var TeamAllocation = artifacts.require("./TeamAllocation.sol");
var PillarToken = artifacts.require("./PillarToken.sol");
const presaleStartBlock = 0;
const presaleEndBlock = 1000;
const icoStartBlock = 0;
const icoEndBlock = 10000000;

const multiSigWallet = '0x5c83618afc51c8d51a7957cf3d36b25489b6aa57'
const threeYearIcedStorage = '0xe36f85190ba15e683701cabd483b011e141fe37e';
const tenYearIcedStorage = '0x2862f287c344ddf1ab4d6540874733901ccd9662';
/*
const multiSigWallet = '0xa0c82828a7d8e54ec699347690d9eedfe428027b'
const threeYearIcedStorage = '0x7d0f8ccea9413fd88c8e882bab5c39405fbeaefe';
const tenYearIcedStorage = '0x4af80735a22eb782be064a5054321d2841b0f5b7';
*/
module.exports = function(deployer) {

  deployer.deploy(PillarPresale,presaleStartBlock,presaleEndBlock,multiSigWallet);
  deployer.deploy(TeamAllocation);
  deployer.deploy(PillarToken,multiSigWallet,icoStartBlock,icoEndBlock,tenYearIcedStorage);

};
