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
       require(checkBook[_name], "Book doesn't exists");
       _;
   }

   modifier sendsEnoughMoney(){
       require(LIB.balanceOf(msg.sender) > 100000000000000000,"Not enough LIB");
       _;
   }

   modifier verifySigner(bytes32 hashedMessage, uint8 v, bytes32 r, bytes32 s, address receiver){
       require(_recoverSigner(hashedMessage, v, r, s) == receiver, 'Receiver did not sign the message');
    
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

   function wrapWithSignature(bytes32 hashedMessage, uint8 v, bytes32 r, bytes32 s, address receiver) public payable verifySigner(hashedMessage,v,r,s,receiver) {
        require(msg.value >0, "Minimum of 1 WEI is required");
		LIB.mint(receiver, msg.value);
		emit TokensMinted(receiver, msg.value);
	}

   function _recoverSigner(bytes32 hashedMessage, uint8 v, bytes32 r, bytes32 s)internal returns (address){
       bytes32 messageDigest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashedMessage));
       return ecrecover(messageDigest, v, r, s);
   }

   function showAvailable() external view  returns (string[] memory){
       return availableBooks;
   }

   function showRenters (string calldata _name) external view returns (address[] memory){
       return booksMap[_name].renters;
   }
   
   function addBook(string calldata _name, uint _count) external onlyOwner {
       require(!checkBook[_name], "Book already exists");

       address[] memory renterArr;
       Book memory newBook = Book({name:_name, count:_count, renters:renterArr});
       
       availableBooks.push(_name);
       checkBook[_name] = true;
       checkBookCount[_name] = _count;
       booksMap[_name] = newBook;

       emit NewBookAdded(_name,_count);
   }

   function permitRentBook(string calldata _bookName,uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
    external
    isAvailable(_bookName) 
    sendsEnoughMoney 
     {
         

        LIBToken(LIB).permit(msg.sender,address(this),value,deadline,v,r,s);
        LIBToken(LIB).transferFrom(msg.sender, address(this), 100000000000000000);

        checkBookCount[_bookName] -= 1;
        booksMap[_bookName].renters.push(msg.sender);

        emit BookRented(_bookName, msg.sender);
   }

   function delegateRentBook (bytes32 hashedMessage, uint8 v, bytes32 r, bytes32 s, address renter,string calldata _bookName) external payable 
   isAvailable(_bookName) 
   sendsEnoughMoney 
   verifySigner(hashedMessage,v,r,s,renter){
      require(checkBookCount[_bookName] > 0, "No more available copies");

    LIB.transferFrom(msg.sender, address(this), 100000000000000000);

    checkBookCount[_bookName] -= 1;
    booksMap[_bookName].renters.push(renter);

    emit BookRented(_bookName, renter);
   }

   function rentBook(string calldata _name) external payable isAvailable(_name) sendsEnoughMoney{

       require(checkBookCount[_name] > 0, "No more available copies");

       LIB.transferFrom(msg.sender, address(this), 100000000000000000);
       
       checkBookCount[_name] -= 1;
       booksMap[_name].renters.push(msg.sender);

       emit BookRented(_name, msg.sender);
   }

   function returnBook(string calldata _name) external isAvailable(_name) {
    //    Don't allow returning more books, than initially available in the library
        require(checkBookCount[_name] != booksMap[_name].count, "All copies have been returned already");

        checkBookCount[_name] += 1;
        
     emit BookReturned(_name, msg.sender);
   }

   function withdrawCoins() public onlyOwner{
       uint256 balance = LIB.balanceOf(address(this));
       
       require(balance > 1, "Not enough balance to withdraw");

       LIB.burn(balance);
       payable(msg.sender).transfer(balance);

       emit TokenWithDrawal (msg.sender,balance);
   }


}
