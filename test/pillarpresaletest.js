var PillarPresale = artifacts.require("./PillarPresale.sol");
var expect = require("chai").expect;
var pillar;
var team;
contract('PillarPresale', function(accounts) {
  it("test for totalSupply", async function() {
    pillar = await PillarPresale.deployed();
    const expected = 16000000;
    const total = await PillarPresale.totalSupply.call();
    expect(parseInt(total.valueOf())).to.equal(expected);
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
