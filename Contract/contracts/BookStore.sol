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

   function showAvailable() external view  returns (string[] memory){
       return availableBooks;
   }

   function showRenters (string calldata _name) external view returns (address[] memory){
       return booksMap[_name].renters;
   }
   
   function addBook(string calldata _name, uint _count) external {
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

   function rentBook(string calldata _name) external isAvailable(_name){
       if(checkBookCount[_name] < 1){
           revert BookOutOfStock();
       }
       
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


}
