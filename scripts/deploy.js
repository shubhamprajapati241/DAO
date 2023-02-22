const hre = require("hardhat");

async function main() {
  const DAO = await hre.ethers.getContractFactory("DAO");
  const dao = await DAO.deploy();
  await dao.deployed();
  console.log("DAO SC address : " + dao.address);
}

main().catch((error) => {
  console.log(error);
  process.exitcode = 1;
});
