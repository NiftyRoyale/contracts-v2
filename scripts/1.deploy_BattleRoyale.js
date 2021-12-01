async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const BattleRoyale = await ethers.getContractFactory("BattleRoyale");
    const BattleRoyaleContract = await BattleRoyale.deploy();
  
    console.log("BattleRoyaleContract address:", BattleRoyaleContract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });