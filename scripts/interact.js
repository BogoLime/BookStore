
const { ethers } = require("hardhat");
const hre = require("hardhat");
require('dotenv').config()

const LibABI = require ("../artifacts/contracts/LIBToken.sol/LIBToken.json")
const {abi} = require("../artifacts/contracts/BookStore.sol/BookStore.json")

async function interact() {
    const provider = new hre.ethers.providers.getDefaultProvider("ropsten")
    const signer =  new hre.ethers.Wallet(process.env["PRIVATE_KEY"],provider)
    const contract = new hre.ethers.Contract("0xAc34cFeC932f631026F744C53d7C5f2D1dc5cA3cw", abi, signer)

    const libContractAddr = await contract.LIB();
	
	  const libContract = new ethers.Contract(libContractAddr, LibABI.abi, signer)

  
    // // 1
    // let transaction = await contract.addBook("Boat",5)
    // let receipt = await transaction.wait()

    // if(receipt.status !== 1){
    //   console.log("Transaction failed")
    //   return
    // }
    // console.log(`Book added to store`)


    const parsedEth = hre.ethers.utils.parseEther("0.2")
    trx = await contract.wrap({value:parsedEth})

    console.log("Minting")
    await trx.wait()
    console.log("Done")

    console.log("Minted for account", await libContract.balanceOf(signer.address) )

    // // 1.1
    // transaction = await contract.addBook("Plane",5)
    // receipt = await transaction.wait()

    // if(receipt.status !== 1){
    //   console.log("Transaction failed")
    //   return
    // }
    // console.log(`Book added to store`)

    // // 2
    // const availableBooks = await contract.showAvailable()
    // console.log(`Available books,  ${availableBooks}`)

    // // 2.1
    // let bookCount = await contract.checkBookCount("Boat")
    // console.log(`Books count,  ${bookCount}`)

    // // 3
    // transaction = await contract.rentBook("Boat")
    // receipt =  await transaction.wait()
    // console.log("Book Rented")

    // bookCount = await contract.checkBookCount("Boat")
    // console.log(`Books count,  ${bookCount}`)

    // // 3.2
    // transaction = await contract.rentBook("Boat")
    // receipt =  await transaction.wait()
    // console.log("Book Rented")

    // bookCount = await contract.checkBookCount("Boat")
    // console.log(`Books count,  ${bookCount}`)

    // // 3.3
    // transaction = await contract.rentBook("Boat")
    // receipt =  await transaction.wait()
    // console.log("Book Rented")

    // const availableBooks = await contract.showAvailable()
    // console.log(`Available books,  ${availableBooks}`)

    // bookCount = await contract.checkBookCount("Zaratustra")
    // console.log(`Books count,  ${bookCount}`)

    // // // 3.4
    // let rentners = await contract.showRenters("Boat")
    // console.log(`Rentners,  ${rentners}`)

    // // 4
    // transaction = await contract.returnBook("Boat")
    // receipt =  await transaction.wait()
    // console.log("Book returned")

    // bookCount = await contract.checkBookCount("Boat")
    // console.log(`Books count,  ${bookCount}`)

    // //5
    // transaction = await contract.returnBook("Boat")
    // receipt =  await transaction.wait()
    // console.log("Book returned")

    // bookCount = await contract.checkBookCount("Boat")
    // console.log(`Books count,  ${bookCount}`)

    // rentners = await contract.showRenters("Boat")
    // console.log(`Rentners,  ${rentners}`)


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
interact()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
