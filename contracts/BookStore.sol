//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract BookStore {

   struct Book {
       bool available;
       string name;
       bool rented;
   }
   
   string[] public availableBooks;
   mapping( string => Book ) booksMap;

   modifier isAvailable(string calldata  _name){
       require(booksMap[_name].available, "Book is not available");
       _;
   }

   function showAvailable() external view  returns (string[] memory){
       return availableBooks;
   }
   
   function addBook(string calldata _name) external {
       if(booksMap[_name].available){
           revert("Book already exists");
       }

       Book memory newBook = Book({available:true,name:_name,rented:false});
       
       booksMap[_name] = newBook;
       availableBooks.push(_name);
   }

   function rentBook(string calldata _name) external isAvailable(_name){
       if(booksMap[_name].rented){
           revert("Book is rented already");
       }
       
       booksMap[_name].rented = true;
   }

   function isRented(string calldata _name) external view isAvailable(_name) returns (bool){
     return booksMap[_name].rented;
   }

   function checkAvailability(string calldata _name) external view returns (bool){
     return booksMap[_name].available;
   }

   function returnBook(string calldata _name) external isAvailable(_name) {
       
        if(!booksMap[_name].rented){
           revert("Book is not rented currently");
       }

        booksMap[_name].rented = false;

   }


}
