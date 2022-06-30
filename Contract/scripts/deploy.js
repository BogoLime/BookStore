const hre = require("hardhat");
require('dotenv').config()

async function  deploy(){
    hre.run("compile")
    const provider = new hre.ethers.providers.InfuraProvider("ropsten",process.env["INFURA_KEY"])
    const wallet = new hre.ethers.Wallet(process.env["PRIVATE_KEY"],provider)
    let factory = await hre.ethers.getContractFactory("BookStore")
    factory = factory.connect(wallet)

    console.log("Started deploying contract")
    let contract  = await factory.deploy()

    contract = await contract.deployed()
    console.log("Deployed contract at", contract.address)
    console.log("Contract signed by", contract.signer.address)
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
