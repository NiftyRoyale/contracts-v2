const BattleRoyalePiece = artifacts.require("BattleRoyalePiece");
const { BN } = require("web3-utils");

module.exports = async function (deployer) {
  await deployer.deploy(
    BattleRoyalePiece,
    "NiftyRoyale",
    "NYR",
    new BN('10000000000000000'),
    5,
    100,
    "https://app.niftyroyale.com/1",
    "https://app.niftyroyale.com/2"
  );

  return;
};
