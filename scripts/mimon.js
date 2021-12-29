const hre = require('hardhat')

async function main() {
  const baseURI = 'https://api.mimons.io/mimon/'
  const devAddress = '0xCea1d08a2497abf300Ea3F0EF3F954993B4e5ab7'
  const openseaProxyContract = '0xa5409ec958c83c3f309868babaca7c86dcb077c1'

  const Mimon = await hre.ethers.getContractFactory('Mimon')

  const mimon = await Mimon.deploy(baseURI, devAddress, openseaProxyContract)
  await mimon.deployed()

  console.log('Mimon deployed to:', mimon.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
