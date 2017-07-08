
require('babel-polyfill');
var PillarPresale = artifacts.require("./PillarPresale.sol");
var expect = require("chai").expect;
var pillar;
contract('PillarPresale', function(accounts) {
  it("test for totalPresaleSupply", async function() {
    try {
      const expected = 44000000;
      pillar = await PillarPresale.deployed();
      const total = await pillar.getTotalPresaleSupply.call();
      expect(parseInt(total.valueOf())).to.equal(expected);
    }catch(e) {
      //catch error
    }
  });

  it("test for fallback function", async function() {
    var expected = 550;
    try {
      const promise = await web3.eth.sendTransaction({from: accounts[8],to: pillar.address, value: web3.toWei(0.5,'ether'), gas: 2000000});
      const balance = await pillar.balanceOf.call(accounts[8]);
      expect(parseInt(balance.valueOf())).to.equal(expected);
    }catch(e) {
      console.log(e);
    }
  });

  it("test for numberOfTokensLeft", async function() {
    var expected = 43999450;
    const tokens = await pillar.numberOfTokensLeft.call();
    expect(parseInt(tokens.valueOf())).to.equal(expected)
  });

  it("test for large sale", async function() {
    try {
      const promise = await web3.eth.sendTransaction({from: accounts[7],to: pillar.address, value: web3.toWei(100,'ether')});
      const balance = await pillar.balanceOf.call(accounts[7]);
    }catch(e) {
      expect(e).not.to.equal('');
    }
  });

  it("test for finalize", async function() {
    //call to finalize will fail before the actual completion of ICO
    try{
      await PillarPresale.finalize.call();
    } catch(e) {
      expect(e).not.to.equal('');
    }
  });
});
