const hre = require('hardhat')

async function main() {
  const TestContract = await hre.ethers.getContractFactory('TestContract')
  const testContract = await TestContract.deploy()
  await testContract.deployed()
  console.log(`TestContract deployed to: ${testContract.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
  