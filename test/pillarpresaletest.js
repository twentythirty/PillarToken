require('babel-polyfill');
var PillarPresale = artifacts.require("./PillarPresale.sol");
var expect = require("chai").expect;
var pillar;
contract('PillarPresale', function(accounts) {

  it("test for totalSupply", async function() {
    pillar = await PillarPresale.deployed();
    const expected = 16000000;
    const total = await pillar.totalSupply.call();
    expect(parseInt(total.valueOf())).to.equal(expected);
  });

  it("test for fallback function", async function() {
    var expected = 500;
    try {
      //console.log(pillar.address);
      const promise = await web3.eth.sendTransaction({from: accounts[8],to: pillar.address, value: web3.toWei(0.5,'ether')});
      console.log(promise);
      const balance = await pillar.balanceOf.call(accounts[8]);
      console.log(balance);
      //expect(parseInt(balance.valueOf())).to.equal(expected);
    }catch(e) {
      console.log(e);
    }
  });

  it("test for numberOfTokensLeft", async function() {
    var expected = 15999500;
    const tokens = await pillar.numberOfTokensLeft.call();
    //expect(parseInt(tokens.valueOf())).to.equal(expected)
  });

  it("test for balanceOf", async function() {
    var expected1 = 350000;
    const balance1 = await pillar.balanceOf.call(accounts[0]);
    //expect(parseInt(balance1.valueOf())).to.equal(expected1);
    var expected2 = 175000;
    const balance2 = await pillar.balanceOf.call(accounts[1]);
    //expect(parseInt(balance2.valueOf())).to.equal(expected2);
    var expected3 = 0;
    const balance3 = await pillar.balanceOf.call(accounts[2]);
    //expect(parseInt(balance3.valueOf())).to.equal(expected3);
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
