
const hre = require("hardhat");

async function main() {
    const accounts = await hre.ethers.getSigners();   

    console.log(accounts[0].address);

}
main()