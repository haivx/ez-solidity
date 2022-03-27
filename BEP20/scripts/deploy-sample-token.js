const hre = require("hardhat");

async function main() {

  // We get the contract to deploy
  const SampleToken = await hre.ethers.getContractFactory("SampleToken");
  const sampleToken = await SampleToken.deploy();

  await sampleToken.deployed();

  console.log("SampleToken deployed to:", sampleToken.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
