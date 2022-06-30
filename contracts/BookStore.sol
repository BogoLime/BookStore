//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";



error BookNotExisting();

error BookOutOfStock();

error BookAlreadyExists();

/// All copies have already been returned.
/// @param count total available copies of the book.
error AllCopiesReturned(uint256 count);

contract BookStore {

   struct Book {
       string name;
       uint256 count;
   }
   
   string[] public availableBooks;
   mapping( string => bool ) public checkBook;
   mapping ( string => uint256 ) public checkBookCount;
   mapping (string => Book ) private booksMap;
   mapping( string => address[]) private checkRenters;

   modifier isAvailable(string calldata  _name){
       if(!checkBook[_name]){
           revert BookNotExisting();
       }
       _;
   }

   event NewBookAdded(string indexed name, uint256 count);
   event BookRented(string indexed name, address indexed renter);
   event BookReturned(string indexed name, address indexed renter);

   function showAvailable() external view  returns (string[] memory){
       return availableBooks;
   }

   function showRenters (string calldata _name) external view returns (address[] memory){
       return checkRenters[_name];
   }
   
   function addBook(Book calldata book) external {
       if(checkBook[book.name]){
           revert BookAlreadyExists();
       }

       Book memory newBook = Book({name:book.name,count:book.count});
       
       availableBooks.push(book.name);
       checkBook[book.name] = true;
       checkBookCount[book.name] = book.count;
       booksMap[book.name] = newBook;

       emit NewBookAdded(book.name,book.count);
   }

   function rentBook(string calldata _name) external isAvailable(_name){
       if(checkBookCount[_name] < 1){
           revert BookOutOfStock();
       }
       
       checkBookCount[_name] -= 1;
       checkRenters[_name].push(msg.sender);

       emit BookRented(_name, msg.sender);
   }

   function AllBooksReturned(string calldata _name) external isAvailable(_name) {
    //    Don't allow returning more books, than initially available in the library
        if(checkBookCount[_name] == booksMap[_name].count){
           revert AllCopiesReturned(booksMap[_name].count);
       }

        checkBookCount[_name] += 1;
        
     emit BookReturned(_name, msg.sender);
   }


}
