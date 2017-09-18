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

    modifier onlyRegistratorOwner {
        require(msg.sender == registrator.owner());
        _;
    }

    modifier onlyRegistratorOrRegistratorOwner {
        require(msg.sender == address(registrator) || msg.sender == registrator.owner());
        _;
    }

}