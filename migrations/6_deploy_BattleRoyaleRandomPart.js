const BattleRoyaleRandomPart = artifacts.require("BattleRoyaleRandomPart");
const { BN } = require("web3-utils");

module.exports = async function (deployer) {
  await deployer.deploy(
    BattleRoyaleRandomPart,
    "NiftyRoyale",
    "NYR",
    new BN('10000000000000000'),
    5,
    100
  );

  return;
};
