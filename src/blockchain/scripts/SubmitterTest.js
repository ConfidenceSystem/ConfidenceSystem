
const hre = require("hardhat");

async function main() {

    function sleep(milliseconds) {
        const date = Date.now();
        let currentDate = null;
        do {
          currentDate = Date.now();
        } while (currentDate - date < milliseconds);
      }
      
      console.log("Hello");
      sleep(2000);
      console.log("World!");
      


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

    await systemsubmitter.SubmitSystem('blah', 1, 1, 0, 600, 2);

   let account0bal = await mocktoken.GetBalancePublic(accounts[0].address);
   let account1bal = await mocktoken.GetBalancePublic(accounts[1].address);
   let account1rep = await mockstaker.GetTotalRep(accounts[1].address);


   console.log("Submitter balance is:", account0bal);
   console.log("Auditor balance is:", account1bal);
   console.log("Auditor rep is:", account1rep);

    await systemsubmitter.FundSystem('blah', mockescrow.address, mocktoken.address)

    const TimeWindow = await systemsubmitter.StartStakingWindow('blah');
    //console.log("Staking Time Window ends at", TimeWindow);

    await systemsubmitter.StakeRep('blah', 500, mockstaker.address, accounts[1].address);

    await systemsubmitter.StartTimeWindow('blah'); 
    console.log("time window started");
    sleep(5000);
    //await mockescrow.CheckTime('blah',systemsubmitter.address);
    await mockescrow.PayOut('blah',systemsubmitter.address,mockstaker.address, accounts[1].address, mocktoken.address);

    account0bal = await mocktoken.GetBalancePublic(accounts[0].address);
    account1bal = await mocktoken.GetBalancePublic(accounts[1].address);
    account1rep = await mockstaker.GetTotalRep(accounts[1].address);


    console.log("Submitter balance is:", account0bal);
    console.log("Auditor balance is:", account1bal);
    console.log("Auditor rep is:", account1rep);
    


    
    
  




// const SystemDetails = await systemsubmitter.GetSystemDetails('blah');


 //  for (i=0; i<10; i++){
 //  console.log(SystemDetails[i],)
 //  }

   

}

main()