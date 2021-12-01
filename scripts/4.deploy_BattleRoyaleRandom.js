async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const BattleRoyaleRandom = await ethers.getContractFactory("BattleRoyaleRandom");
    const BattleRoyaleRandomContract = await BattleRoyaleRandom.deploy();
  
    console.log("BattleRoyaleRandomContract address:", BattleRoyaleRandomContract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });