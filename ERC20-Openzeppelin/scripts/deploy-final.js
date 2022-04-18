// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  let petty
  let gold 
  let tokenSale
  let reserve
  let marketplace
  let defaultFeeRate = 0;
  let defaultFeeDecimal = 0;

  // We get the contract to deploy
  const Petty = await hre.ethers.getContractFactory("Petty");
  petty = await Petty.deploy();

  await petty.deployed();

  console.log("Petty deployed to:", petty.address);

  const Gold = await hre.ethers.getContractFactory("Gold");
  gold = await Gold.deploy();
  await gold.deployed();
  console.log("Gold deployed to:", gold.address);

  const TokenSale = await hre.ethers.getContractFactory("TokenSale");
  tokenSale = await TokenSale.deploy(gold.address);

  await tokenSale.deployed();
  console.log("TokenSale deployed to:", tokenSale.address);

  const transferTx = await gold.transfer(tokenSale.address, ethers.utils.parseUnits("1000000", "ether"))
  await transferTx.wait()


  const Reserve = await hre.ethers.getContractFactory("Reserve");
  reserve = await Reserve.deploy(gold.address);
  await reserve.deployed();
  console.log("Gold deployed to:", reserve.address);

  const MarketPlace = await hre.ethers.getContractFactory("Marketplace");
  marketplace = await MarketPlace.deploy(petty.address, defaultFeeDecimal, defaultFeeRate, reserve.address);
  await marketplace.deployed();
  console.log("Gold deployed to:", marketplace.address);

  const addPaymenTx = await marketplace.addPaymentToken(gold.address)
  await addPaymenTx.wait();

  console.log("Gold is payment token? true or false: ", await marketplace.isPaymentTokenSupported(gold.address))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
