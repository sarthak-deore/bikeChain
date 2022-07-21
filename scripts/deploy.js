const hre = require("hardhat");

async function main() {
  const BikeChain = await hre.ethers.getContractFactory("BikeChain");
  const bikeChain = await BikeChain.deploy();

  await bikeChain.deployed();

  console.log("Deployed to: ", bikeChain.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
