pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./Registrator.sol";
import "./Registered.sol";
import "./Business.sol";
import "./Customer.sol";
import "./CoinSale.sol";


contract Offer is Registered, Ownable, AvoidRecursiveCall {

    CoinSale coinSale;

    function Offer(Registrator registratorArg, CoinSale coinSaleArg) Registered(registratorArg) {
        coinSale = coinSaleArg;
    }

    function show(Customer customer) onlyRegistrator {
        require(registrator == customer.registrator());
        require(registrator == coinSale.business().registrator());
        require(registrator.allCustomers(customer));
        require(registrator.allBusinesses(coinSale.business()));
        
        //TODO: Send ERC20 coins to customer
        //ERC20 token = ERC20(0x348438257643856483256475683425);
        //token.transfer(customer.owner());
    }

}