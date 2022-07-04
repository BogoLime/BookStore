//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./LIBToken.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

error BookNotExisting();

error BookOutOfStock();

error BookAlreadyExists();

error NoTokenBalance();


/// All copies have already been returned.
/// @param count total available copies of the book.
error AllCopiesReturned(uint256 count);

contract BookStore is Ownable{

    LIBToken public LIB;

    constructor(){
        LIB = new LIBToken();
    }


   struct Book {
       string name;
       uint256 count;
       address[] renters;
   }
   
   string[] public availableBooks;
   mapping( string => bool ) public checkBook;
   mapping ( string => uint256 ) public checkBookCount;
   mapping (string => Book ) private booksMap;

   modifier isAvailable(string calldata  _name){
       if(!checkBook[_name]){
           revert BookNotExisting();
       }
       _;
   }

   event NewBookAdded(string indexed name, uint256 count);
   event BookRented(string indexed name, address indexed renter);
   event BookReturned(string indexed name, address indexed renter);
   event TokensMinted (address indexed owner, uint256 amount);
   event TokensBurned (address indexed owner, uint256 amount);
   event TokenWithDrawal(address indexed owner, uint256 amount);

   function wrap() public payable{
       require(msg.value >0, "Minimum of 1 WEI is required");
       LIB.mint(msg.sender,msg.value);
       emit TokensMinted(msg.sender, msg.value);
   }

   function unwrap(uint256 value) external {
       require(value >0, "Minimum of 1 WEI is required");
       LIB.transferFrom(msg.sender, address(this), value);
       LIB.burn(value);
       payable(msg.sender).transfer(value);
       emit TokensBurned(msg.sender,value);
   }

   function showAvailable() external view  returns (string[] memory){
       return availableBooks;
   }

   function showRenters (string calldata _name) external view returns (address[] memory){
       return booksMap[_name].renters;
   }
   
   function addBook(string calldata _name, uint _count) external onlyOwner {
       if(checkBook[_name]){
           revert BookAlreadyExists();
       }

       address[] memory renterArr;
       Book memory newBook = Book({name:_name, count:_count, renters:renterArr});
       
       availableBooks.push(_name);
       checkBook[_name] = true;
       checkBookCount[_name] = _count;
       booksMap[_name] = newBook;

       emit NewBookAdded(_name,_count);
   }

   function rentBook(string calldata _name) external payable isAvailable(_name){
       if(msg.value < 100000000000000000){
           revert("Rent sum send is lower than 0.1 ETH");
       }

       if(checkBookCount[_name] < 1){
           revert BookOutOfStock();
       }

        // Minting coins on the bookstore account
       LIB.mint(address(this),msg.value);
       
       checkBookCount[_name] -= 1;
       booksMap[_name].renters.push(msg.sender);

       emit BookRented(_name, msg.sender);
   }

   function returnBook(string calldata _name) external isAvailable(_name) {
    //    Don't allow returning more books, than initially available in the library
        if(checkBookCount[_name] == booksMap[_name].count){
           revert AllCopiesReturned(booksMap[_name].count);
       }

        checkBookCount[_name] += 1;
        
     emit BookReturned(_name, msg.sender);
   }

   function withdrawCoins() public onlyOwner{
       uint256 balance = LIB.balanceOf(address(this));
       
       if(balance < 1){
           revert NoTokenBalance();
       }

       LIB.burn(balance);
       payable(msg.sender).transfer(balance);

       emit TokenWithDrawal (msg.sender,balance);
   }


}
