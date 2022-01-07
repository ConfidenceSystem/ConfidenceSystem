
const hre = require("hardhat");

async function main() {

 const SystemSubmitter = await hre.ethers.getContractFactory("SubmitSystemContract");
 const systemsubmitter = await SystemSubmitter.deploy();
 await systemsubmitter.deployed();
 console.log("submitter deployed to:", systemsubmitter.address);

 const string = await systemsubmitter.RequestComplexity('blah');

 console.log(string);


}

main()