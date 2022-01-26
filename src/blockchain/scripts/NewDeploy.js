
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




    Interface = await hre.ethers.getContractFactory("InterfaceContract")
    const interface = await Interface.deploy(accounts[0].address);
    await interface.deployed();
    console.log("interface deployed to:", interface.address);

    SubmittedSystems1 = await hre.ethers.getContractFactory("SubmittedSystemsContract")
    const submittedsystems = await SubmittedSystems1.deploy(accounts[0].address);
    await submittedsystems.deployed();
    console.log("submittedsystems deployed to:", submittedsystems.address);

    Payouts = await hre.ethers.getContractFactory("PayoutsContract")
    const payouts = await Payouts.deploy(accounts[0].address);
    await payouts.deployed();
    console.log("payouts deployed to:", payouts.address);

    const NewUsers = await hre.ethers.getContractFactory("NewUsersContract");
    const users = await NewUsers.deploy(accounts[0].address);
    await users.deployed();
    console.log("users deployed to:", users.address);

    MockToken = await hre.ethers.getContractFactory("MockToken")
    const mocktoken = await MockToken.deploy(accounts[0].address);
    await mocktoken.deployed();
    console.log("mocktoken deployed to:", mocktoken.address);


    Triage = await hre.ethers.getContractFactory("TriageContract")
    const triage = await Triage.deploy(accounts[0].address);
    await triage.deployed();
    console.log("triage deployed to:", triage.address);


    await interface.SetAddress(mocktoken.address, payouts.address, users.address, submittedsystems.address, triage.address, interface.address);
    await submittedsystems.SetAddress(mocktoken.address, payouts.address, users.address, submittedsystems.address, triage.address, interface.address);
    await users.SetAddress(mocktoken.address, payouts.address, users.address, submittedsystems.address, triage.address, interface.address);
    await payouts.SetAddress(mocktoken.address, payouts.address, users.address, submittedsystems.address, triage.address, interface.address);
    await mocktoken.SetAddress(mocktoken.address, payouts.address, users.address, submittedsystems.address, triage.address, interface.address);
    await triage.SetAddress(mocktoken.address, payouts.address, users.address, submittedsystems.address, triage.address, interface.address);

  


    /*
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

   
*/
}

main()