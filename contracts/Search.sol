pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./Registered.sol";
import "./Offer.sol";
import "./Business.sol";
import "./Customer.sol";


contract Search is Registered, Ownable, AvoidRecursiveCall {

    function Search(Registrator registratorArg) Registered(registratorArg) {
    }

    function showOfferToCustomer(Offer offer, Customer customer) onlyOwner avoidRecursiveCall {
        offer.showTo(customer);
    }

}
