const hre = require('hardhat');

async function main() {
  // We get the contract to deploy
  const factory = await hre.ethers.getContractFactory('Web3T3Certificate');
  const deploy = await factory.deploy();

  const instance = await deploy.deployed();

  console.log('Deployed to:', instance.address);

  await instance.grantRole(
    '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',
    '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
