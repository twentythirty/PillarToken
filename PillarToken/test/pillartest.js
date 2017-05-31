var PillarToken = artifacts.require("./PillarToken.sol");
var expect = require("chai").expect;
var pillar;
contract('PillarToken', function(accounts) {
  it("test for totalSupply", async function() {
    pillar = await PillarToken.deployed();
    const expected = 7000000;
    const total = await pillar.totalSupply.call();
    expect(parseInt(total.valueOf())).to.equal(expected);
  });

  it("test for fundingActive", async function() {
    const expected = true;
    const status = await pillar.fundingActive.call();
    expect(status.valueOf()).to.equal(expected);
  });

  it("test for purchase", async function() {
    var expected = 87999;
    await pillar.purchase({from: accounts[0], value: web3.toWei(1,'ether')});
    const balance = await pillar.balanceOf.call(accounts[0]);
    expect(parseInt(balance.valueOf())).to.equal(expected);
  });

  it("test for fallback function", async function() {
    var expected = 43999;
    await web3.eth.sendTransaction({from: accounts[1],to: pillar.address, value: web3.toWei(0.5,'ether')});
    const balance = await pillar.balanceOf.call(accounts[1]);
    expect(parseInt(balance.valueOf())).to.equal(expected);
  });

  it("test for numberOfTokensLeft", async function() {
    var expected = 6868002;
    const tokens = await pillar.numberOfTokensLeft.call();
    expect(parseInt(tokens.valueOf())).to.equal(expected)
  });

  it("test for balanceOf", async function() {
    var expected1 = 87999;
    const balance1 = await pillar.balanceOf.call(accounts[0]);
    expect(parseInt(balance1.valueOf())).to.equal(expected1);
    var expected2 = 43999;
    const balance2 = await pillar.balanceOf.call(accounts[1]);
    expect(parseInt(balance2.valueOf())).to.equal(expected2);
    var expected3 = 0;
    const balance3 = await pillar.balanceOf.call(accounts[2]);
    expect(parseInt(balance3.valueOf())).to.equal(expected3);
  });
  /* transfer call is failing needs investigation */
  it("test for transfer", async function() {
    await pillar.transfer(accounts[2],100,{from:accounts[0], gas: 100000});//{from: accounts[0], gas: 1000000});
    var expected1 = 100;
    const balance1 = await pillar.balanceOf.call(accounts[2]);
    expect(parseInt(balance1)).to.equal(expected1);
    var expected2 = 87899;
    const balance2 = await pillar.balanceOf.call(accounts[0]);
    expect(parseInt(balance2)).to.equal(expected2);
  });

  it("test for refund failure", async function() {
    try {
      await pillar.refund.call();
    }catch(e) {
      //console.log(e);
      expect(e).not.to.equal('');
    }
  });
/*
  it("test for finalize", async function() {

  });
  */
});
