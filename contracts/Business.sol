pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./Registrator.sol";
import "./Registered.sol";


contract Business is Registered, Ownable, AvoidRecursiveCall {

    CoinSale[] public coinSales;
    
    event CoinSaleAdded(address wallet);

    function Business(Registrator registratorArg) Registered(registratorArg) {
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