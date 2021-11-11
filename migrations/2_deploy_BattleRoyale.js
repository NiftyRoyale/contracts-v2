const BattleRoyale = artifacts.require("BattleRoyale");
const { BN } = require("web3-utils");

module.exports = async function (deployer) {
  await deployer.deploy(
    BattleRoyale,
    "NiftyRoyale",
    "NYR",
    new BN('10000000000000000'),
    5,
    100,
    "weiq23sfxcvji92312asdkjwesdflj",
    "https://app.niftyroyale.com/"
  );

  return;
};
