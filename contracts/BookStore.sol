//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract BookStore {

   struct Book {
       string name;
       int count;
   }
   
   string[] public availableBooks;
   mapping( string => bool ) checkBook;
   mapping ( string => int )  checkBookCount;
   mapping (string => Book ) private booksMap;
   mapping( string => address[]) checkRenters;

   modifier isAvailable(string calldata  _name){
       require(checkBook[_name], "Book is not available");
       _;
   }

   function showAvailable() external view  returns (string[] memory){
       return availableBooks;
   }
   
   function addBook(Book calldata book) external {
       if(checkBook[book.name]){
           revert("Book already exists");
       }

       Book memory newBook = Book({name:book.name,count:book.count});
       
       availableBooks.push(book.name);
       checkBook[book.name] = true;
       checkBookCount[book.name] = book.count;
       booksMap[book.name] = book;
   }

   function rentBook(string calldata _name) external isAvailable(_name){
       if(checkBookCount[_name] < 1){
           revert("No currently available copies");
       }
       
       checkBookCount[_name] -= 1;
       checkRenters[_name].push(msg.sender);
   }

   function returnBook(string calldata _name) external isAvailable(_name) {
    //    Don't allow returning more books, than initially available in the library
        if(checkBookCount[_name] == booksMap[_name].count){
           revert("All copies have been returned already");
       }

        checkBookCount[_name] += 1;

   }


}
