// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "hardhat/console.sol";

contract BikeChain {
    address owner;
    uint ownerBalance;

    constructor(){
        owner = msg.sender;
    }

    struct Renter {
        address payable walletAddress;
        string firstName;
        string lastName;
        bool canRent;
        bool active;
        uint balance;
        uint due;
        uint start;
        uint end;

    }

    mapping (address=>Renter) public renters;

    function addRenter(address payable walletAddress,string memory firstName,string memory lastName,bool canRent,bool active,uint balance,uint due,uint start,uint end) public{
        renters[walletAddress] = Renter(walletAddress,firstName,lastName,canRent,active,balance,due,start,end);
    }

    modifier isRenter (address walletAddress){
        require(msg.sender == walletAddress, "You can manage only your own account!");
        _;
        
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorised personnel!");
        _;
    }


    function checkOut(address walletAddress) public isRenter(walletAddress){
        require(renters[walletAddress].due == 0, "You have dues pending!");
        require(renters[walletAddress].canRent == true, "You cannot rent at the moment!");
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canRent = false;
    }

    function checkIn(address walletAddress) public isRenter(walletAddress){
        require(renters[walletAddress].active == true, "Please check-out a bike first!");
        renters[walletAddress].active = false;
        renters[walletAddress].end = block.timestamp;
        setDue(walletAddress);

    }

    function renterTimeSpan(uint start,uint end) internal pure returns(uint){
        return end - start;
    }

    function getTotalDuration(address walletAddress) public isRenter(walletAddress) view returns(uint){
        if(renters[walletAddress].start == 0 || renters[walletAddress].end == 0){
            return 0;
        } else {
        uint timespan = renterTimeSpan(renters[walletAddress].start,renters[walletAddress].end);
        uint timespanInMinutes = timespan / 60;
        return timespanInMinutes;
        }
        
    }

    // Check contract balance
    function balanceOf() view public onlyOwner() returns(uint) {
        return address(this).balance;
    }

    // Check owner's profits
    function getOwnerBalance () view public onlyOwner() returns(uint) {
        return ownerBalance;
    }

    function withdrawOwnerBalance() payable public onlyOwner() {
        payable(owner).transfer(ownerBalance);
        ownerBalance = 0;
    }


    function balanceOfRenter(address walletAddress) public isRenter(walletAddress) view returns(uint){
        return renters[walletAddress].balance;
    }

    function setDue(address walletAddress) internal {
        uint timespanInMinutes = getTotalDuration(walletAddress);
        uint fiveMinuteIncrements = timespanInMinutes/5;
        renters[walletAddress].due = fiveMinuteIncrements*5000000000000000+5000000000000000;
    }

    function canRentBike(address walletAddress) internal {
        if(renters[walletAddress].due == 0){
            renters[walletAddress].canRent = true;
        }
    }

    function deposit(address walletAddress) payable public isRenter(walletAddress) {
        renters[walletAddress].balance += msg.value;
    }

    function checkOwner(address walletAddress) view public onlyOwner() returns(bool){
        if(renters[walletAddress].walletAddress==owner){
            return true;
        } 

        return false;
    }

    function makePayment(address walletAddress, uint amount) public isRenter(walletAddress) {
        require(renters[walletAddress].due > 0, "You don't have any dues!");
        require(renters[walletAddress].due >= amount, "Please enter an amount less than our equal to your dues");
        require(renters[walletAddress].balance >= amount, "You don't have enough funds, please make a deposit!");
        renters[walletAddress].balance -= amount;
        renters[walletAddress].due -= amount;
        ownerBalance += amount;
        canRentBike(walletAddress);
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
        
    }

    function getDue(address walletAddress) public isRenter(walletAddress) view returns(uint){
        return renters[walletAddress].due;
    }

    function getRenter(address walletAddress) public isRenter(walletAddress) view returns(string memory firstName, string memory lastName, bool canRent, bool active){
        firstName = renters[walletAddress].firstName;
        lastName = renters[walletAddress].lastName;
        canRent = renters[walletAddress].canRent;
        active = renters[walletAddress].active;
    }

    function renterExists(address walletAddress) public isRenter(walletAddress) view returns(bool){
        if (renters[walletAddress].walletAddress != address(0)){
            return true;
        }

        return false;
    }
}