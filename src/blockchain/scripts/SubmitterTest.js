
const hre = require("hardhat");

async function main() {
    const SystemSubmitter = await hre.ethers.getContractFactory("SubmitSystemContract");
    const systemsubmitter = await SystemSubmitter.deploy();
    await systemsubmitter.deployed();
    console.log("submitter deployed to:", systemsubmitter.address);

    const MockStaker = await hre.ethers.getContractFactory("MockStaker");
    const mockstaker = await MockStaker.deploy();
    await mockstaker.deployed();
    console.log("mockstaker deployed to:", mockstaker.address);

    MockEscrow = await hre.ethers.getContractFactory("MockEscrow")
    const mockescrow = await MockEscrow.deploy();
    await mockescrow.deployed();
    console.log("mockescrow deployed to:", mockescrow.address);

    MockToken = await hre.ethers.getContractFactory("MockToken")
    const mocktoken = await MockToken.deploy();
    await mocktoken.deployed();
    console.log("mocktoken deployed to:", mocktoken.address);

    const accounts = await hre.ethers.getSigners();   


    
    await mockstaker.SetRep(accounts[1].address)
    await mocktoken.SetBalance(accounts[0].address, 1200);

    await systemsubmitter.SubmitSystem('blah', 10, 10, 0, 600, 2);
    await systemsubmitter.FundSystem('blah', mockescrow.address, mocktoken.address)

    const TimeWindow = await systemsubmitter.StartStakingWindow('blah');
    console.log("Staking Time Window ends at", TimeWindow);

    await systemsubmitter.StakeRep('blah', 500, mockstaker.address, accounts[1].address);

    setTimeout(function(){
         systemsubmitter.StartTimeWindow('blah'); 
         console.log("time window started");
    }, 11000);



    const SystemDetails = await systemsubmitter.GetSystemDetails('blah');


   for (i=0; i<10; i++){
   console.log(SystemDetails[i],)
   }

   

}

main()