pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./CoinSale.sol";
import "./Business.sol";
import "./Customer.sol";
import "./Search.sol";


contract Registrator is Ownable, AvoidRecursiveCall {

    function isContractAddress(address addr) constant returns(bool) {
        uint size;
        assembly { 
            size := extcodesize(addr) 
        }
        return size > 0;
    }

    // Registered contracts
    mapping(address => bool) public allCustomers;
    mapping(address => bool) public allBusinesses;
    mapping(address => bool) public allCoinSales;
    mapping(address => bool) public allSearches;
    Customer[] public customers;
    Business[] public businesses;
    CoinSale[] public coinSales;
    Search[] public searches;

    // Trusted properties, can only be filled by Registartor owner
    mapping(address => Customer) public customerByWallet;
    mapping(address => Business) public businessByIcoCreator;
    mapping(uint256 => CoinSale.Participation) public participationByTxid;
    
    // Event needs to be handled by Registrator Service and then call addVerifiedParticipation
    event AskToVerifyTransaction(uint256 txid);
    // Event needs to be handled by Registrator Service and then call addVerifiedIcoCreator
    event AskToVerifyIcoCreator(Business business, address icoCreator);
    
    function customersCount() constant returns(uint) {
        return customers.length;
    }

    function businessesCount() constant returns(uint) {
        return businesses.length;
    }

    function coinSalesCount() constant returns(uint) {
        return coinSales.length;
    }

    function searchesCount() constant returns(uint) {
        return searches.length;
    }

    function createCustomer() avoidRecursiveCall returns(Customer) {
        Customer customer = new Customer(this);
        customer.transferOwnership(msg.sender);
        allCustomers[customer] = true;
        customers.push(customer);
        return customer;
    }

    function deleteCustomer(Customer customer) avoidRecursiveCall {
        require(customer.owner() == msg.sender);
        require(allCustomers[customer]);
        delete allCustomers[customer];

        for (uint i = 0; i < customers.length; i++) {
            if (customers[i] == customer) {
                delete customers[i];
                customers[i] = customers[customers.length - 1];
                customers.length -= 1;
                return;
            }
        }

        revert();
    }

    function createBusiness() avoidRecursiveCall returns(Business) {
        Business business = new Business(this);
        business.transferOwnership(msg.sender);
        allBusinesses[business] = true;
        businesses.push(business);
        return business;
    }

    function deleteBusiness(Business business) avoidRecursiveCall {
        require(business.owner() == msg.sender);
        require(allBusinesses[business]);
        delete allBusinesses[business];

        for (uint i = 0; i < businesses.length; i++) {
            if (businesses[i] == business) {
                delete businesses[i];
                businesses[i] = businesses[businesses.length - 1];
                businesses.length -= 1;
                return;
            }
        }

        revert();
    }

    function createCoinSale() avoidRecursiveCall onlyOwner returns(CoinSale) {
        CoinSale coinSale = new CoinSale(this);
        coinSale.transferOwnership(owner);
        allCoinSales[coinSale] = true;
        coinSales.push(coinSale);
        return coinSale;
    }

    function deleteCoinSale(CoinSale coinSale) avoidRecursiveCall onlyOwner {
        require(coinSale.owner() == msg.sender);
        require(allCoinSales[coinSale]);
        delete allCoinSales[coinSale];

        for (uint i = 0; i < coinSales.length; i++) {
            if (coinSales[i] == coinSale) {
                delete coinSales[i];
                coinSales[i] = coinSales[coinSales.length - 1];
                coinSales.length -= 1;
                return;
            }
        }

        revert();
    }

    function createSearch() avoidRecursiveCall returns(Search) {
        Search search = new Search(this);
        search.transferOwnership(msg.sender);
        allSearches[search] = true;
        searches.push(search);
        return search;
    }

    function deleteSearch(Search search) avoidRecursiveCall {
        require(search.owner() == msg.sender);
        require(allSearches[search]);
        delete allCoinSales[search];

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

    // Call only from wallet, not from smart-contract
    // to verify this wallet belongs to this customer
    function askToVerifyCustomerWallet(Customer customer) avoidRecursiveCall {
        require(!isContractAddress(msg.sender)); //TODO: remove line to support smart-contract wallets

        customerByWallet[msg.sender] = customer;
        customer.addWallet(msg.sender);
    }

    // Call only from wallet, not from smart-contract
    // to verify this wallet belongs to this ICO creator
    function askToVerifyIcoCreator(Business business) avoidRecursiveCall {
        require(!isContractAddress(msg.sender)); //TODO: remove line to support smart-contract wallets
        require(businessByIcoCreator[msg.sender] == address(0x0));

        AskToVerifyIcoCreator(business, msg.sender);
    }

    function askToVerifyTransaction(uint256 txid) avoidRecursiveCall {
        AskToVerifyTransaction(txid);
    }

    function addVerifiedParticipation(
        uint256 txid,
        uint date,
        CoinSale coinSale,
        address wallet,
        uint etherValue) avoidRecursiveCall onlyOwner
    {
        require(coinSale.owner() == owner);

        participationByTxid[txid] = CoinSale.Participation({
            txid: txid,
            date: date,
            coinSale: coinSale,
            wallet: wallet,
            etherValue: etherValue
        });

        Customer customer = customerByWallet[wallet];
        customer.addTransaction(txid);
    }

    function addVerifiedIcoCreator(
        Business business,
        address icoCreator,
        CoinSale coinSale) avoidRecursiveCall onlyOwner
    {
        require(business.registrator() == this);
        require(coinSale.owner() == owner);
        require(allCoinSales[coinSale]);

        businessByIcoCreator[icoCreator] = business;
        business.addCoinSale(coinSale);
    }

    function checkCustomer(Customer customer) constant returns(bool) {
        return checkCustomerWallets(customer) && checkCustomerTransactions(customer);
    }

    function checkCustomerWallets(Customer customer) constant returns(bool) {
        require(customer.registrator() == this);
        require(allCustomers[customer]);

        for (uint i = 0; i < customer.walletsCount(); i++) {
            if (customerByWallet[customer.wallets(i)] != customer) {
                return false;
            }
        }
        return true;
    }

    function checkCustomerTransactions(Customer customer) constant returns(bool) {
        require(customer.registrator() == this);
        require(allCustomers[customer]);

        for (uint i = 0; i < customer.transactionsCount(); i++) {
            uint256 txid = customer.transactions(i);
            CoinSale.Participation storage participation = participationByTxid[txid];
            if (customerByWallet[participation.wallet] != customer) {
                return false;
            }
        }
        return true;
    }

    function checkBusiness(Business business) constant returns(bool) {
        return checkBusinessCoinSales(business);
    }

    function checkBusinessCoinSales(Business business) constant returns(bool) {
        require(business.registrator() == this);
        require(allBusinesses[business]);

        for (uint i = 0; i < business.coinSalesCount(); i++) {
            CoinSale coinSale = business.coinSales(i);
            require(coinSale.owner() == owner);
            if (businessByIcoCreator[coinSale.icoCreator()] != business) {
                return false;
            }
        }
        return true;
    }

}
