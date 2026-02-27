require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    // Tenderly Virtual TestNet (LIVE)
    tenderly: {
      url: "https://virtual.base-sepolia.eu.rpc.tenderly.co/7360d884-4b4b-4385-a8b7-4d02aebc1c72",
      accounts: ["0x0c4ad5af11eee32f5389fd35a64e64c2bad466191fc6543ba8e0efd5941ab5a4"],
      chainId: 84532
    },
    // Base Testnet (Goerli)
    baseGoerli: {
      url: "https://goerli.base.org",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 84531
    },
    // Base Mainnet (for later)
    baseMainnet: {
      url: "https://mainnet.base.org",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 8453
    }
  },
  etherscan: {
    apiKey: {
      baseGoerli: process.env.BASESCAN_API_KEY || "",
      baseMainnet: process.env.BASESCAN_API_KEY || ""
    },
    customChains: [
      {
        network: "baseGoerli",
        chainId: 84531,
        urls: {
          apiURL: "https://api-goerli.basescan.org/api",
          browserURL: "https://goerli.basescan.org"
        }
      },
      {
        network: "baseMainnet",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org"
        }
      }
    ]
  }
};
