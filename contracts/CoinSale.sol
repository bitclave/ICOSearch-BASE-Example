pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./Business.sol";


contract CoinSale is Ownable, AvoidRecursiveCall {

    struct Participation {
        uint256 txid;
        uint date;
        CoinSale coinSale;
        address wallet;
        uint etherValue;
    }

    address public icoContract;
    address public icoCreator;
    uint public dateStart;
    uint public dateEnd;
    Business public business;

    function setIcoContract(address icoContractArg) avoidRecursiveCall onlyOwner {
        icoContract = icoContractArg;
    }

    function setIcoCreator(address icoCreatorArg) avoidRecursiveCall onlyOwner {
        icoCreator = icoCreatorArg;
    }

    function setDateStart(uint dateStartArg) avoidRecursiveCall onlyOwner {
        dateStart = dateStartArg;
    }

    function setDateEnd(uint dateEndArg) avoidRecursiveCall onlyOwner {
        dateEnd = dateEndArg;
    }

    function setBusiness(Business businessArg) avoidRecursiveCall onlyOwner {
        business = businessArg;
    }

}
