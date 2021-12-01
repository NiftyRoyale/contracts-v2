const BattleRoyaleRandom = artifacts.require("BattleRoyaleRandom");
const { BN } = require("web3-utils");

module.exports = async function (deployer) {
  await deployer.deploy(
    BattleRoyaleRandom,
    "NiftyRoyale",
    "NYR",
    new BN('10000000000000000'),
    5,
    100
  );

  return;
};
