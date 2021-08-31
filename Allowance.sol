//SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

/*
Import Owner {Ownable}, a simpler mechanism with a single owner "role" that can 
be assigned to a single account from Open Zeppelin contract. Better for audit purposes, 
as we are re using audited smart contracts.
*/

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

//Contract that will take care of the allowance characteristics of the wallet. Inhereted from Open Zeppelin Ownable.
contract Allowance is Ownable {

    /*
    Event to trigger when allowance is changed, showing:
        -the address that requested the change (the owner)
        -the beneficiary address
        -the old and new allowed amount for the beneficiary
    */
    event AllowanceChanged(address indexed _forWho, address indexed _byWhom, uint _oldAmount, uint _newAmount);
    
    // Variable containing the mapping of address and amount allowed to withdraw 
    mapping(address => uint) public allowance;

    // Check if msg sender is the owner of the contract (stablished when deploying the contract)
    function isOwner() internal view returns(bool) {
        return owner() == msg.sender;
    }

    // Set allowance for an given addresss (only by the owner)
    function setAllowance(address _who, uint _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }

    /* Modifier: checks if its the owner, or a third party. 
    In this last case, requires to operate for and amount equal or less than their allowance
    */
    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "You are not allowed!");
        _;
    }

    // Reduces given allowance
    function reduceAllowance(address _who, uint _amount) internal ownerOrAllowed(_amount) {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who] - _amount);
        allowance[_who] -= _amount;
    }

}

