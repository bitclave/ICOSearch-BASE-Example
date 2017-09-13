pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./Registrator.sol";
import "./Registered.sol";
import "./Offer.sol";


contract Business is Registered, Ownable, AvoidRecursiveCall {

    mapping(address => bool) public allOffers;
    mapping(address => bool) public allCoinSales;
    Offer[] public offers;
    CoinSale[] public coinSales;
    
    event CoinSaleAdded(address wallet);

    function Business(Registrator registratorArg) Registered(registratorArg) {
    }

    function offersCount() constant returns(uint) {
        return offers.length;
    }    

    function createOffer(CoinSale coinSale) onlyOwner returns(Offer) {
        require(allCoinSales[coinSale]);
        Offer offer = new Offer(registrator, coinSale);
        offer.transferOwnership(msg.sender);
        allOffers[offer] = true;
        offers.push(offer);
        return offer;
    }

    function deleteOffer(Offer offer) onlyOwner {
        require(offer.owner() == msg.sender);
        require(allOffers[offer]);
        delete allOffers[offer];

        for (uint i = 0; i < offers.length; i++) {
            if (offers[i] == offer) {
                delete offers[i];
                offers[i] = offers[offers.length - 1];
                offers.length -= 1;
                return;
            }
        }

        revert();
    }

    function coinSalesCount() constant returns(uint) {
        return coinSales.length;
    }

    function addCoinSale(CoinSale coinSale) avoidRecursiveCall onlyRegistrator {
        for (uint i = 0; i < coinSales.length; i++) {
            require(coinSales[i] != coinSale);
        }
        allCoinSales[coinSale] = true;
        coinSales.push(coinSale);
        CoinSaleAdded(coinSale);
    }

}