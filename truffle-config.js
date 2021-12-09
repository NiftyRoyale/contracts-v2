const HDWalletProvider = require("@truffle/hdwallet-provider");
const secretMumbai = require("./secret.mumbai.json");
const secretKovan = require("./secret.kovan.json");
const secretRinkeby = require("./secret.rinkeby.json");

module.exports = {
  // Uncommenting the defaults below
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  networks: {
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          secretRinkeby.mnemonic,
          `https://rinkeby.infura.io/v3/${secretRinkeby.infura_api_key}`
        ),
      network_id: 4,
      timeoutBlocks: 50000,
      skipDryRun: true,
    },
    kovan: {
      provider: () =>
        new HDWalletProvider(
          secretKovan.mnemonic,
          `https://kovan.infura.io/v3/${secretKovan.infura_api_key}`
        ),
      network_id: 42,
      timeoutBlocks: 50000,
      skipDryRun: true,
    },
    mumbai: {
      provider: () => new HDWalletProvider(secretMumbai.mnemonic, `https://rpc-mumbai.maticvigil.com`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 5000,
      skipDryRun: true
    },
    matic: {
      provider: () => new HDWalletProvider(secretMumbai.mnemonic, `https://rpc-mainnet.maticvigil.com`),
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 5000,
      skipDryRun: true
    },
  },
  compilers: {
    solc: {
      version: "0.8.6",
    },
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    etherscan: secretKovan.etherscan_api_key,
    polygonscan: secretMumbai.polygonscan_api_key
  },
};
