pragma solidity ^0.4.2;

import "./Registrator.sol";


contract Registered {

    Registrator public registrator;

    function Registered(Registrator registratorArg) {
        registrator = registratorArg;
    }

    modifier onlyRegistrator {
        require(msg.sender == address(registrator));
        _;
    }

}