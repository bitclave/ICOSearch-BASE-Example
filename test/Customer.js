require('babel-register');
require('babel-polyfill');

//import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import expectThrow from './Helpers/expectThrow';

var Registrator = artifacts.require("./Registrator.sol");
var Customer = artifacts.require("./Customer.sol");
var CoinSale = artifacts.require("./CoinSale.sol");

contract('Customer', function(accounts) {

    it("should add wallets via Registrator", async function() {
        var anyAccount = accounts[0];
        var registratorAccount = accounts[1];
        var customerAccount = accounts[2];
        var customerWallet1 = accounts[3];
        var customerWallet2 = accounts[4];
        var customerWallet3 = accounts[5];

        var registrator = await Registrator.new({from: registratorAccount});
        var customer = await Customer.new(registrator.address, {from: customerAccount});

        assert.equal(await customer.walletsCount.call(), 0, "No one wallet were added");

        await registrator.askToVerifyCustomerWallet(customer.address, {from: customerWallet1});
        assert.equal(await customer.walletsCount.call(), 1, "Wallet #1 was added");

        await registrator.askToVerifyCustomerWallet(customer.address, {from: customerWallet2});
        assert.equal(await customer.walletsCount.call(), 2, "Wallet #2 was added");

        // Wallet #1 cannot be added again
        await expectThrow(registrator.askToVerifyCustomerWallet(customer.address, {from: customerWallet1}));

        // Wallet #2 cannot be added again
        await expectThrow(registrator.askToVerifyCustomerWallet(customer.address, {from: customerWallet2}));

        // Wallet can only be added by Registrator
        await expectThrow(customer.addWallet(customerWallet3, {from: customerWallet3}));
    });

    it("should add participations via Registrator", async function() {
        var anyAccount = accounts[0];
        var registratorAccount = accounts[1];
        var customerAccount = accounts[2];
        var customerWallet1 = accounts[3];

        var txid = 0x12345678;
        var timestamp = + new Date();
        var ethValue = 10;
        
        var registrator = await Registrator.new({from: registratorAccount});
        var customer = await Customer.new(registrator.address, {from: customerAccount});
        await registrator.askToVerifyCustomerWallet(customer.address, {from: customerWallet1});
        
        var event = registrator.AskToVerifyTransaction({_from:web3.eth.coinbase}, {fromBlock: 0, toBlock: 'latest'});
        const promise = new Promise(resolve => event.watch(async function(error, response) {
            event.stopWatching();
            var coinSale = await CoinSale.new({from: registratorAccount});
            await registrator.addVerifiedParticipation(txid, timestamp, coinSale.address, customerWallet1, ethValue, {from: registratorAccount});
            assert.equal(await customer.transactionsCount.call(), 1, "Participation should be added");
            resolve();
        }));
        
        assert.equal(await customer.transactionsCount.call(), 0, "There should be no participations yet");
        await registrator.askToVerifyTransaction(txid, {from: customerAccount});

        return await promise;
    });

});
