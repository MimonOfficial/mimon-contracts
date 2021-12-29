const hre = require('hardhat')

async function main() {
  const openseaPeoxyContract = '0xa5409ec958c83c3f309868babaca7c86dcb077c1'

  const Mimon = await hre.ethers.getContractFactory('Mimon')

  const mimon = await Mimon.deploy('test-uri/')
  await mimon.deployed()

  console.log('Mimon deployed to:', mimon.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
