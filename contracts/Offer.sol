pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./Registrator.sol";
import "./Registered.sol";
import "./Business.sol";
import "./Customer.sol";
import "./CoinSale.sol";
import "./Search.sol";


contract Offer is Registered, Ownable, AvoidRecursiveCall {

    CoinSale public coinSale;
    StandardToken tokenContract;
    uint cpa;

    // Allowed Search engines
    mapping(address => bool) public allSearches;
    Search[] public searches;

    function Offer(Registrator registratorArg, CoinSale coinSaleArg, address tokenContractArg, uint cpaArg) Registered(registratorArg) {
        coinSale = coinSaleArg;
        tokenContract = StandardToken(tokenContractArg);
        cpa = cpaArg;
    }

    function addSearch(Search search) onlyOwner avoidRecursiveCall {
        require(!allSearches[search]);
        allSearches[search] = true;
        searches.push(search);
    }

    function deleteSearch(Search search) onlyOwner avoidRecursiveCall {
        require(allSearches[search]);
        delete allSearches[search];

        for (uint i = 0; i < searches.length; i++) {
            if (searches[i] == search) {
                delete searches[i];
                searches[i] = searches[searches.length - 1];
                searches.length -= 1;
                return;
            }
        }

        revert();
    }

    function showTo(Customer customer) avoidRecursiveCall {
        Search search = Search(msg.sender);
        require(allSearches[search]);

        require(registrator == customer.registrator());
        require(registrator == coinSale.business().registrator());
        require(registrator.allCustomers(customer));
        require(registrator.allBusinesses(coinSale.business()));
        
        // Send ERC20 coins to customer wallet
        tokenContract.transfer(customer.owner(), cpa / 2);
        tokenContract.transfer(search.owner(), cpa / 2);
    }

}