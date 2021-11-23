const BattleRoyaleRandom = artifacts.require("BattleRoyaleRandom");
const { BN } = require("web3-utils");

module.exports = async function (deployer) {
  await deployer.deploy(
    BattleRoyaleRandom,
    "NiftyRoyale",
    "NYR",
    new BN('10000000000000000'),
    5,
    20,
    ["https://app.niftyroyale.com/1", "https://app.niftyroyale.com/2", "https://app.niftyroyale.com/3", "https://app.niftyroyale.com/4", "https://app.niftyroyale.com/5",
      "https://app.niftyroyale.com/6", "https://app.niftyroyale.com/7", "https://app.niftyroyale.com/8", "https://app.niftyroyale.com/9", "https://app.niftyroyale.com/10",
      "https://app.niftyroyale.com/11", "https://app.niftyroyale.com/12", "https://app.niftyroyale.com/13", "https://app.niftyroyale.com/14", "https://app.niftyroyale.com/15",
      "https://app.niftyroyale.com/16", "https://app.niftyroyale.com/17", "https://app.niftyroyale.com/18", "https://app.niftyroyale.com/19", "https://app.niftyroyale.com/20",]
  );

  return;
};
