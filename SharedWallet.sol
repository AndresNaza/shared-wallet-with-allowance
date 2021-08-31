//SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./Allowance.sol";

contract SharedWallet is Allowance {

    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);


    //Override renounce ownership (function provided by OpenZeppelin, to make it not possible on this project
    function renounceOwnership() public virtual override onlyOwner {
        revert("can't renounce Ownership here");
    }
    
    //Receive ether from any address. Emit an event when received.
    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
    
    
    /*Withdraw money functions. Checks:
        -If the wallet has enough money to make the operation.
        -If the sender is:
            -the owner (in which case it can withdraw hole funds) or 
            -a third party (in which case the withdrawal is limited to their allowance -which is reduced then by the amount of the trx-)
    */
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "Contract doesn't own enough money");
        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);

    }
}
