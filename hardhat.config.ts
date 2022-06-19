import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-abi-exporter";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ganache";
import "@openzeppelin/hardhat-upgrades";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

// @ts-ignore
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.14",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    /*hardhat: {
      chainId: 31337,
    },*/
    localhost: {
      chainId: 31337,
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    mumbai: {
      url: process.env.MUMBAI_URL || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      gasPrice: "auto"
    },
    polygon: {
      url: process.env.POLYGON_URL_URL || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    bsc_testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts:  process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
    },
    bsc_mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
      accounts:   process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
    },
    optimism_testnet: {
      url: "https://opt-kovan.g.alchemy.com/v2/",
      chainId: 69,
      gasPrice: "auto",
      accounts:  process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
    },
    ganache: {
      url: "http://127.0.0.1:7545",
      chainId: 1337,
      accounts:  ['0xd3acde496d2650b39485101ddd6eb1820ff133836b2eb609d4fc7c8955866abc']

    },
    hardhat: {
      mining: {
        mempool: {
          order: "fifo"
        }
      },
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ETH_KEY}`,
        blockNumber: 14390000
      },
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "./gas-report.txt",
    noColors: true
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },

// @ts-ignore

  abiExporter: {
    path: './data/abi',
    flat: true,
    only: ["PresaleHolder", "AKX", "PresaleDirectory", "VestingWallet", "PresaleExchange", "Whitelist"]
  }
};

export default config;
