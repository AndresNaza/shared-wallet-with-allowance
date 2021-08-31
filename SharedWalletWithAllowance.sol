//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


contract Owned{
    
    //Define the variable that will store the owner address
    address owner;
    
    //Make the deployment address the owner of the contract
    constructor(){
        owner = msg.sender;
    }
    
    //Create modifier that checks if the owner is the one trying to make changes
    modifier onlyOwner{
        require(msg.sender == owner, 'Only the owner can modify those parameters.');
        _;
    }
    
}


contract SharedWalletWithAllowance is Owned{
    
    //Mapping of addresses and their allowance
    mapping(address => uint) public allowance;
    
    //Deposit funds: Fallback function to receive any amount of ether from any address
    receive() external payable{
        //Just receive ether
    }
    
    //Define allowance
    function defineAllowance(address _address, uint _amount) public onlyOwner{
        allowance[_address] = _amount;
    }
    
    
    //Withdraw funds: NonOwner
    function withdrawFundsNonOwner(address payable _to, uint _amount) public {
        require(_amount <= allowance[_to], 'Cannot withdraw more than the allowed.');
        allowance[_to] -= _amount;
        _to.transfer(_amount);
    }
    
    //Withdraw funds: Owner
    function withdrawFundsOwner(address payable _to, uint _amount) public onlyOwner{
        require(address(this).balance >= _amount, 'Not enough funds for the transaction.');
        _to.transfer(_amount);
    }
    
}