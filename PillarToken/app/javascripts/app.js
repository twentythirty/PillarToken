// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import pillartoken_artifacts from '../../build/contracts/PillarToken.json'
import teamallocation_artifacts from '../../build/contracts/TeamAllocation.json'

// PillarToken is our usable abstraction, which we'll use through the code below.
var PillarToken = contract(pillartoken_artifacts);
var TeamAllocation = contract(teamallocation_artifacts);

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;
var contract_address;

window.App = {
  start: function() {
    var self = this;

    // Bootstrap the PillarToken abstraction for Use.
    PillarToken.setProvider(web3.currentProvider);

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];

      PillarToken.deployed().then(function(instance) {
        contract_address = instance.address;
      });

      self.tokenStats();
      self.refreshStats();
    });
  },

  purchaseTokenFor: function(index) {
    var amount = document.getElementById("amount" + index).value;
    var meta;
    PillarToken.at(contract_address).then(function(instance) {
      meta = instance;
      return meta.purchase({from:accounts[index], value: web3.toWei(amount,'ether'), gasLimit: 4712388, gasPrice:100000000000 });
    }).then(function(value) {
      console.log("Token Purchase successful");
      self.refreshStats();
      self.tokenStats();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error purchasing token; see log");
    });
  },

  tokenStats: function() {
    var meta;
    var total = document.getElementById("total");
    var available = document.getElementById("available");

    PillarToken.deployed().then(function(instance) {
      meta = instance;
      return meta.totalSupply();
    }).then(function(value) {
      console.log("Total supply: " + value);
      total.innerHTML = value;
      return meta.numberOfTokensLeft();
    }).then(function(value) {
      console.log("Available Tokens: " + value);
      available.innerHTML = value;
      return meta.fundingActive();
    }).then(function(value) {
      console.log("Sale Open: " + value);
      sale.innerHTML = value;
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error tokenStats; see log.");
    });
  },

  refreshStats: function() {
    var meta;
    var balance1 = document.getElementById("account1_tokens");
    var balance2 = document.getElementById("account2_tokens");
    var balance3 = document.getElementById("account3_tokens");
    var balance4 = document.getElementById("account4_tokens");
    var balance5 = document.getElementById("account5_tokens");

    PillarToken.deployed().then(function(instance) {
      meta = instance;
      return meta.balanceOf(accounts[1]);
    }).then(function(value) {
      console.log("Balance of " + accounts[1]+" is : " + value);
      balance1.innerHTML = value;
      return meta.balanceOf(accounts[2]);
    }).then(function(value) {
      console.log("Balance of " + accounts[2]+" is : " + value);
      balance2.innerHTML = value;
      return meta.balanceOf(accounts[3]);
    }).then(function(value) {
      console.log("Balance of " + accounts[3]+" is : " + value);
      balance3.innerHTML = value;
      return meta.balanceOf(accounts[4]);
    }).then(function(value) {
      console.log("Balance of " + accounts[4]+" is : " + value);
      balance4.innerHTML = value;
      return meta.balanceOf(accounts[5]);
    }).then(function(value) {
      console.log("Balance of " + accounts[5]+" is : " + value);
      balance5.innerHTML = value;
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error refreshingStats; see log.");
    });
  },

  setStatus: function(message) {
    var status = document.getElementById("status");
    status.innerHTML = message;
  }
};

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 PillarToken, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.start();
});
