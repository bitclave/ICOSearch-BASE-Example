pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./Registrator.sol";


contract Business is Ownable, AvoidRecursiveCall {

    Registrator public registrator;
    CoinSale[] public coinSales;
    
    event CoinSaleAdded(address wallet);

    modifier onlyRegistrator {
        require(msg.sender == address(registrator));
        _;
    }

    function Business(Registrator registratorArg) {
        registrator = registratorArg;
    }

    function coinSalesCount() constant returns(uint) {
        return coinSales.length;
    }

    function addCoinSale(CoinSale coinSale) avoidRecursiveCall onlyRegistrator {
        for (uint i = 0; i < coinSales.length; i++) {
            require(coinSales[i] != coinSale);
        }
        coinSales.push(coinSale);
        CoinSaleAdded(coinSale);
    }

}