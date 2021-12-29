require("@nomiclabs/hardhat-waffle");
require("hardhat-abi-exporter");
require("dotenv").config();

module.exports = {
  solidity: "0.8.10",
  networks: {
    popcateum: {
      url: "https://dataseed.popcateum.org",
      accounts: [process.env.TestPK || ""],
    },
    polygon: {
      url: "https://polygon-rpc.com",
      accounts: [process.env.TestPK || ""],
      gas: 35,
    },
    gorli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: [process.env.TestPK || ""],
    },
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [process.env.TestPK || ""],
    },
  },
  abiExporter: {
    path: "./abi",
    runOnCompile: true,
    clear: true,
    flat: true,
    spacing: 2,
  },
};
