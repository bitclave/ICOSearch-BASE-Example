pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./Registrator.sol";
import "./Registered.sol";
import "./Business.sol";


contract Offer is Registered, Ownable, AvoidRecursiveCall {

    Business business;

    function Offer(Registrator registratorArg, Business businessArg) Registered(registratorArg) {
        business = businessArg;
    }

}