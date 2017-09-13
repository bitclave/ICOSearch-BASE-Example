//import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import expectThrow from './Helpers/expectThrow';

const Registrator = artifacts.require("./Registrator.sol");
const Customer = artifacts.require("./Customer.sol");
const CoinSale = artifacts.require("./CoinSale.sol");

contract('Customer', function([_, registratorAccount, customerAccount, customerWallet1, customerWallet2, customerWallet3]) {

    it("should add wallets via Registrator", async function() {

        const registrator = await Registrator.new({from: registratorAccount});
        await registrator.createCustomer({from: customerAccount});
        const customersCount = await registrator.customersCount.call();
        const customer = Customer.at(await registrator.customers.call(customersCount - 1));

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
    })

    it("should add participations via Registrator", async function() {

        const txid = 0x12345678;
        const timestamp = + new Date();
        const ethValue = 10;

        const registrator = await Registrator.new({from: registratorAccount});
        await registrator.createCustomer({from: customerAccount});
        const customersCount = await registrator.customersCount.call();
        const customer = Customer.at(await registrator.customers.call(customersCount - 1));

        await registrator.askToVerifyCustomerWallet(customer.address, {from: customerWallet1});

        assert.equal(await customer.transactionsCount.call(), 0, "There should be no participations yet");
        await registrator.askToVerifyTransaction(txid, {from: customerAccount});

        const event = registrator.AskToVerifyTransaction({_from:web3.eth.coinbase}, {fromBlock: 'latest'});
        const promise = new Promise(resolve => event.watch(async function(error, response) {

            await registrator.createCoinSale({from: registratorAccount});
            const coinSalesCount = await registrator.coinSalesCount.call();
            const coinSale = CoinSale.at(await registrator.coinSales.call(coinSalesCount - 1));
            await registrator.addVerifiedParticipation(txid, timestamp, coinSale.address, customerWallet1, ethValue, {from: registratorAccount});
            assert.equal(await customer.transactionsCount.call(), 1, "Participation should be added");

            event.stopWatching();
            resolve();
        }));

        await promise;
    })

})
