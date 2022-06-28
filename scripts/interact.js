
const hre = require("hardhat");
require('dotenv').config()

const {abi} = require("../artifacts/contracts/BookStore.sol/BookStore.json")

async function interact() {
    const provider = new hre.ethers.providers.InfuraProvider("ropsten",process.env["INFURA_KEY"])
    const signer =  new hre.ethers.Wallet(process.env["PRIVATE_KEY"],provider)
    const contract = new hre.ethers.Contract(process.env["CONTRACT_ADDR"], abi, signer)
    
    

    // 1
    let transaction = await contract.addBook("Boat")
    let receipt = await transaction.wait()

    if(receipt.status !== 1){
      console.log("Transaction failed")
      return
    }
    console.log(`Book added to store`)

    // 2
    const availableBooks = await contract.showAvailable()
    console.log(`Available books,  ${availableBooks}`)

    // 3
    transaction = await contract.rentBook("Boat")
    receipt =  await transaction.wait()
    console.log("Book Rented")

     
     let isRented = await contract.isRented("Boat")
     console.log("Book rented:", isRented)

    // 4
    transaction = await contract.returnBook("Boat")
    receipt =  await transaction.wait()
    console.log("Book returned")

    
    isRented = await contract.isRented("Boat")
    console.log("Book rented:", isRented)

    //5
    const isAvailable = await contract.checkAvailability("Boat")
    console.log("Book available:", isAvailable)



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
interact()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
