require("@nomiclabs/hardhat-waffle")
require('dotenv').config()

const RPC_URL = process.env.RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

module.exports = {
  solidity: "0.8.11",
  paths: {
    sources: './src/blockchain/contracts',
    cache: './src/blockchain/cache',
    artifacts: './src/frontend/artifacts',
    tests: './tests/blockchain'
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    rinkeby: {
      url: RPC_URL,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  }
};
