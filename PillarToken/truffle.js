module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    testnet: {
      host: "localhost",
      port: 8545,
      network_id: "3",
      from: "0x00e4A3C02834F7d443011Fd0546566EF9814982b"
    }
  }
};
