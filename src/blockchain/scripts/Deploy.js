
const hre = require("hardhat");

async function main() {

   
  

    

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

}
export const escrow = mockescrow.address
export const staker = mockstaker.address
export const systemsubmitter = systemsubmitter.address
export const token = mocktoken.address
export const reality = realitymock.address

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });