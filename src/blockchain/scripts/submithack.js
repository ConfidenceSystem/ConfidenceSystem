
const hre = require("hardhat");

async function main() {

    function sleep(milliseconds) {
        const date = Date.now();
        let currentDate = null;
        do {
          currentDate = Date.now();
        } while (currentDate - date < milliseconds);
      }
      
  


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

    RealityMock = await hre.ethers.getContractFactory("RealityMock")
    const realitymock = await RealityMock.deploy();
    await realitymock.deployed();
    console.log("realitymock deployed to:", realitymock.address);

    MockToken = await hre.ethers.getContractFactory("MockToken")
    const mocktoken = await MockToken.deploy();
    await mocktoken.deployed();
    console.log("mocktoken deployed to:", mocktoken.address);

    const accounts = await hre.ethers.getSigners();   


    
    await mockstaker.SetRep(accounts[1].address)
    await mocktoken.SetBalance(accounts[0].address, 1200);

    await systemsubmitter.SubmitSystem('blah', 2, 2, 0, 600, 2, accounts[3].address, realitymock.address);
    await systemsubmitter.GetComplexity('blah',realitymock.address);


   let account0bal = await mocktoken.GetBalancePublic(accounts[0].address);
   let account1bal = await mocktoken.GetBalancePublic(accounts[1].address);
   let account1rep = await mockstaker.GetTotalRep(accounts[1].address);


   console.log("Submitter balance is:", account0bal);
   console.log("Auditor balance is:", account1bal);
   console.log("Auditor rep is:", account1rep);

    await systemsubmitter.FundSystem('blah', mockescrow.address, mocktoken.address)

    await systemsubmitter.StartStakingWindow('blah');
    await systemsubmitter.StakeRep('blah', 500, mockstaker.address, accounts[1].address);
    sleep(5000);
    await systemsubmitter.StartTimeWindow('blah'); 
    console.log("time window started");
    await systemsubmitter.connect(accounts[2]).SubmitHackHash('blah', 'bleh');
    await systemsubmitter.connect(accounts[2]).SubmitHack('blah', 'bleh', realitymock.address, accounts[3].address);
    await systemsubmitter.connect(accounts[2]).GetHack(accounts[2].address,'blah', realitymock.address, mockescrow.address, mocktoken.address, mockstaker.address);
    sleep(5000);


    await mockescrow.PayOut('blah',systemsubmitter.address,mockstaker.address, accounts[1].address, mocktoken.address, realitymock.address);
    await mockescrow.ReturnUnstaked('blah',systemsubmitter.address,mocktoken.address);

    account0bal = await mocktoken.GetBalancePublic(accounts[0].address);
    account1bal = await mocktoken.GetBalancePublic(accounts[1].address);
    account1rep = await mockstaker.GetTotalRep(accounts[1].address);
    account2bal= await mocktoken.GetBalancePublic(accounts[2].address);
    account2rep = await mockstaker.GetTotalRep(accounts[2].address);


    console.log("Submitter balance is:", account0bal);
    console.log("Auditor balance is:", account1bal);
    console.log("Auditor rep is:", account1rep);
    console.log("hacker balance is:", account2bal);
    console.log("hacker rep is :", account2rep);
    
}

main()