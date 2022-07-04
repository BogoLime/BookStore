const hre = require("hardhat");
require('dotenv').config()

const LibABI = require ("../artifacts/contracts/LIBToken.sol/LIBToken.json")
const BookABI = require("../artifacts/contracts/BookStore.sol/BookStore.json");
const { ethers } = require("hardhat");

async function deployWithLIB (){
    const provider = new hre.ethers.providers.getDefaultProvider("http://localhost:8545");
    const signer = new hre.ethers.Wallet("0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e",provider);
    const bookFactory =  await  hre.ethers.getContractFactory("BookStore",signer);

    // 2
    const bookContract = await bookFactory.deploy();
    console.log("Deploying Contract")
    await bookContract.deployed()
    console.log("Contract deployed")

    const libContractAddr = await bookContract.LIB();
	
	const libContract = new ethers.Contract(libContractAddr, LibABI.abi, signer)

    console.log("LIB Adress", libContract.address)


    // 2.1
    // let bytes32 = await ethers.utils.formatBytes32String("MINTER_ROLE")
    // let trx = await libContract.grantRole(bytes32,bookContract.address)

    // await trx.wait()

    // bytes32 = await ethers.utils.formatBytes32String("MINTER_ROLE")
    // trx = await libContract.grantRole(bytes32,signer.address)

    // await trx.wait()

    console.log("Wallet Role", await libContract.hasRole(ethers.utils.formatBytes32String("MINTER_ROLE"),signer.address))
    console.log("Books Role", await libContract.hasRole(ethers.utils.formatBytes32String("MINTER_ROLE"),bookContract.address))

    //3
    const parsedEth = hre.ethers.utils.parseEther("1")
     trx = await bookContract.wrap({value:parsedEth})

    console.log("Minting")
    await trx.wait()
    console.log("Done")

    console.log("Books balance",await provider.getBalance(bookContract.address))
    console.log("Signer balance",await libContract.balanceOf( signer.address))
    console.log("LIB balance", await provider.getBalance(signer.address))

    trx = await libContract.approve(bookContract.address,parsedEth)
    await trx.wait()
    console.log("Approved")

    trx = await bookContract.unwrap(parsedEth)
    await trx.wait()

    console.log("Books balance",await provider.getBalance(bookContract.address))
    console.log("LIB balance",await libContract.balanceOf( signer.address))
    console.log("LIB balance", await provider.getBalance(signer.address))

    trx = await bookContract.addBook("Boat",8)
    await trx.wait()
    console.log("Book added")

    trx = await bookContract.rentBook("Boat", {value:parsedEth})
    await trx.wait()
    console.log("Book rented")
    trx = await bookContract.rentBook("Boat", {value:parsedEth})
    await trx.wait()
    console.log("Book rented")
    trx = await bookContract.rentBook("Boat", {value:parsedEth})
    await trx.wait()
    console.log("Book rented")
    trx = await bookContract.rentBook("Boat", {value:parsedEth})
    await trx.wait()
    console.log("Book rented")
    trx = await bookContract.rentBook("Boat", {value:parsedEth})
    await trx.wait()
    console.log("Book rented")
    trx = await bookContract.rentBook("Boat", {value:parsedEth})
    await trx.wait()
    console.log("Book rented")
    trx = await bookContract.rentBook("Boat", {value:parsedEth})
    await trx.wait()
    console.log("Book rented")
    
    
    console.log("Store Coin balance",await libContract.balanceOf( bookContract.address))
    console.log("Admin balance",await provider.getBalance( signer.address))

    console.log("Withdrawing Coins")
    trx =  await bookContract.withdrawCoins()
    await trx.wait()

    console.log("Store Coin balance",await libContract.balanceOf( signer.address))
    console.log("Admin balance",await provider.getBalance( signer.address))

}

deployWithLIB()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
