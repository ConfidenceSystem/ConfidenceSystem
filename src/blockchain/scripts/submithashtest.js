
const hre = require("hardhat");

async function main() {

 const SystemSubmitter = await hre.ethers.getContractFactory("SubmitSystemContract");
 const systemsubmitter = await SystemSubmitter.deploy();
 await systemsubmitter.deployed();
 console.log("submitter deployed to:", systemsubmitter.address);

 await systemsubmitter.SubmitHackHash('blah','pretendimahash');
 await systemsubmitter.SubmitHack('blah','ipfslinktoexplanation', 0);

 const hash1 = await systemsubmitter.GetHash('blah', 0);
 const explanation1 = await systemsubmitter.GetExplanation('blah', 0);
 console.log(hash1);
 console.log(explanation1);


}

main()