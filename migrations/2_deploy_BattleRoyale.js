const BattleRoyale = artifacts.require("BattleRoyale");
const { BN } = require("web3-utils");

module.exports = function (deployer) {
  await deployer.deploy(
    BattleRoyale,
    "NiftyRoyale",
    "NYR",
    new BN('10000000000000000'),
    5,
    100,
    "https://https://app.niftyroyale.com/"
  );

  return;
};
