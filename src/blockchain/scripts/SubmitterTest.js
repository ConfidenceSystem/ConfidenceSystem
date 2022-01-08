
const hre = require("hardhat");

async function main() {

    function sleep(milliseconds) {
        const date = Date.now();
        let currentDate = null;
        do {
          currentDate = Date.now();
        } while (currentDate - date < milliseconds);
      }
      
  


    const accounts = await hre.ethers.getSigners();   


    const MockStaker = await hre.ethers.getContractFactory("MockStaker");
    const mockstaker = await MockStaker.deploy(accounts[0].address);
    await mockstaker.deployed();
    console.log("mockstaker deployed to:", mockstaker.address);

    MockEscrow = await hre.ethers.getContractFactory("MockEscrow")
    const mockescrow = await MockEscrow.deploy(accounts[0].address);
    await mockescrow.deployed();
    console.log("mockescrow deployed to:", mockescrow.address);

    RealityMock = await hre.ethers.getContractFactory("RealityMock")
    const realitymock = await RealityMock.deploy();
    await realitymock.deployed();
    console.log("realitymock deployed to:", realitymock.address);

    MockToken = await hre.ethers.getContractFactory("MockToken")
    const mocktoken = await MockToken.deploy(accounts[0].address);
    await mocktoken.deployed();
    console.log("mocktoken deployed to:", mocktoken.address);


    const SystemSubmitter = await hre.ethers.getContractFactory("SubmitSystemContract");
    const systemsubmitter = await SystemSubmitter.deploy(accounts[0].address);
    await systemsubmitter.deployed();
    console.log("submitter deployed to:", systemsubmitter.address);

    await systemsubmitter.SetAddress(mockstaker.address,mockescrow.address,mocktoken.address,realitymock.address,accounts[3].address);
    await mockescrow.SetAddress(mockstaker.address, systemsubmitter.address, mocktoken.address, realitymock.address, accounts[3].address);
    await mocktoken.SetAddress(mockescrow.address, systemsubmitter.address, mockstaker.address, realitymock.address, accounts[3].address);
    await mockstaker.SetAddress(mockescrow.address, systemsubmitter.address, mocktoken.address, realitymock.address, accounts[3].address);
  


    
    await mockstaker.SetRep(accounts[1].address)
    await mocktoken.SetBalance(accounts[0].address, 1200);

    await systemsubmitter.SubmitSystem('blah', 2, 2, 600);
    await systemsubmitter.GetComplexity('blah');

   let account0bal = await mocktoken.GetBalancePublic(accounts[0].address);
   let account1bal = await mocktoken.GetBalancePublic(accounts[1].address);
   let account1rep = await mockstaker.GetTotalRep(accounts[1].address);


   console.log("Submitter balance is:", account0bal);
   console.log("Auditor balance is:", account1bal);
   console.log("Auditor rep is:", account1rep);

    await systemsubmitter.FundSystem('blah')

    await systemsubmitter.StartStakingWindow('blah');
    await systemsubmitter.StakeRep('blah', 500, accounts[1].address);
    sleep(5000);
    await systemsubmitter.StartTimeWindow('blah'); 
    console.log("time window started");
    sleep(5000);

    await mockescrow.PayOut('blah', accounts[1].address);
    await mockescrow.ReturnUnstaked('blah');

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