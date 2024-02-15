import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
require('dotenv').config()

const PRIVATE_KEY = process.env.PRIVATE_KEY!

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200, //(2 ^ 32) - 1,
      },
    },
  },
  defaultNetwork: 'polygonMumbai',
  networks: {
    //   goerli: {
    //     url: process.env.GOERLI_RPC_URL!,
    //     accounts: [PRIVATE_KEY],
    //   },
    //   polygon: {
    //     url: process.env.POLYGON_RPC_URL!,
    //     accounts: [PRIVATE_KEY],
    //   },
    polygonMumbai: {
      url: process.env.MUMBAI_RPC_URL!,
      accounts: [PRIVATE_KEY],
    },
    //   bscMainnet: {
    //     url: process.env.BSC_MAINNET_RPC_URL!,
    //     accounts: [PRIVATE_KEY],
    //   },
    //   bscTestnet: {
    //     url: process.env.BSC_TESTNET_RPC_URL!,
    //     accounts: [PRIVATE_KEY],
    //   },
  },
  etherscan: {
    apiKey: {
      //     goerli: process.env.ETHERSCAN_API_KEY!,
      //     polygon: process.env.POLYGONSCAN_API_KEY!,
      polygonMumbai: process.env.POLYGONSCAN_API_KEY!,
      //     bscMainnet: process.env.BINANCESCAN_API_KEY!,
      //     bscTestnet: process.env.BINANCESCAN_API_KEY!,
    },
  },
}

export default config
