async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const ChainlinkBattle = await ethers.getContractFactory("ChainlinkBattle");
    const ChainlinkBattleContract = await ChainlinkBattle.deploy();
  
    console.log("ChainlinkBattleContract address:", ChainlinkBattleContract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });