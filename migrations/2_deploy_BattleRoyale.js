const BattleRoyale = artifacts.require('BattleRoyale')
const { BN } = require('web3-utils')

module.exports = async function (deployer) {
  await deployer.deploy(
    BattleRoyale,
    'Nifty Royale X Tester: Nifty Royale NFT',
    'TVBR',
    new BN('10000000000000000'),
    5,
    100,
    'QmPS3DjUdXZAFXq3SgDPqHapnqQqWqd25VX87Ri4dWTkxE',
    'Qmdy4U4V9JHoFgN4uQ7st9ZDrN7KGf2bZ6fe99kw8kASrQ',
    'https://niftyroyale.mypinata.cloud/ipfs/',
    new BN('2556100800')
  )

  return
}
