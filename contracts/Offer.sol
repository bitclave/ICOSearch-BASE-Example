pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./Registrator.sol";
import "./Registered.sol";
import "./Business.sol";


contract Offer is Registered, Ownable, AvoidRecursiveCall {

    Business business;

    function Offer(Registrator registratorArg, Business businessArg) Registered(registratorArg) {
        business = businessArg;
    }

    function show(Customer customer) onlyRegistrator {
        require(registrator == customer.registrator());
        require(registrator == business.registrator());
        require(registrator.allCustomers(customer));
        require(registrator.allBusinesses(business));
        
        //TODO: Send ERC20 coins to customer
        //ERC20 token = ERC20(0x348438257643856483256475683425);
        //token.transfer(customer.owner());
    }

}