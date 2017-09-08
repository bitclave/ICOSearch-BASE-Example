pragma solidity ^0.4.2;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./helpers/AvoidRecursiveCall.sol";
import "./CoinSale.sol";
import "./Business.sol";
import "./Customer.sol";


contract Registrator is Ownable, AvoidRecursiveCall {

    function isContractAddress(address addr) constant returns(bool) {
        uint size;
        assembly { 
            size := extcodesize(addr) 
        }
        return size > 0;
    }

    // Trusted properties, can only be filled by Registartor owner
    CoinSale[] coinSales;
    mapping(address => Customer) public customerByWallet;
    mapping(address => Business) public businessByIcoCreator;
    mapping(uint256 => CoinSale.Participation) public participationByTxid;
    
    // Event needs to be handled by Registrator Service and then call addVerifiedParticipation
    event AskToVerifyTransaction(uint256 txid);
    // Event needs to be handled by Registrator Service and then call addVerifiedIcoCreator
    event AskToVerifyIcoCreator(Business business, address icoCreator);
    
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

        businessByIcoCreator[icoCreator] = business;
        coinSale.setIcoCreator(icoCreator);
        coinSale.setBusiness(business);
        business.addCoinSale(coinSale);
    }

    function addCoinSale(CoinSale coinSale) avoidRecursiveCall onlyOwner {
        for (uint i = 0; i < coinSales.length; i++) {
            require(coinSales[i].icoContract() != coinSale.icoContract());
        }
        coinSales.push(coinSale);
    }

    function checkCustomer(Customer customer) constant returns(bool) {
        return checkCustomerWallets(customer) && checkCustomerTransactions(customer);
    }

    function checkCustomerWallets(Customer customer) constant returns(bool) {
        require(customer.registrator() == this);

        for (uint i = 0; i < customer.walletsCount(); i++) {
            if (customerByWallet[customer.wallets(i)] != customer) {
                return false;
            }
        }
        return true;
    }

    function checkCustomerTransactions(Customer customer) constant returns(bool) {
        require(customer.registrator() == this);

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
