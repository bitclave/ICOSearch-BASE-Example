//import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import expectThrow from './Helpers/expectThrow';

var Registrator = artifacts.require("./Registrator.sol");
var Business = artifacts.require("./Business.sol");
var CoinSale = artifacts.require("./CoinSale.sol");

contract('Business', function([_, registratorAccount, businessAccount, businessWallet1, businessWallet2, businessWallet3]) {

    it("should add coin sales via Registrator", async function() {

        var registrator = await Registrator.new({from: registratorAccount});
        await registrator.createBusiness({from: businessAccount});
        const businessesCount = await registrator.businessesCount.call();
        const business = Business.at(await registrator.businesses.call(businessesCount - 1));

        assert.equal(await business.coinSalesCount.call(), 0, "No one coin sales were added");

        {
            // Ask Registrator to verify and add coin sale
            await registrator.askToVerifyIcoCreator(business.address, {from: businessWallet1});

            const event = registrator.AskToVerifyIcoCreator({_from:web3.eth.coinbase}, {fromBlock: 'latest'});
            const promise = new Promise(resolve => event.watch(async function(error, response) {

                // Check event arguments
                assert.equal(response.args.business, business.address, "Check business argument");
                assert.equal(response.args.icoCreator, businessWallet1, "Check icoCreator argument");

                // Create or find coin sale
                await registrator.createCoinSale({from: registratorAccount});
                const coinSalesCount = await registrator.coinSalesCount.call();
                const coinSale = CoinSale.at(await registrator.coinSales.call(coinSalesCount - 1));
                await coinSale.setIcoCreator(businessWallet1, {from: registratorAccount});
                await coinSale.setBusiness(business.address, {from: registratorAccount});

                // Call back
                await registrator.addVerifiedIcoCreator(business.address, businessWallet1, coinSale.address, {from: registratorAccount});
                assert.equal(await business.coinSalesCount.call(), 1, "Coin sale should be added");

                event.stopWatching();
                resolve();
            }));

            await promise;
        }

        {
            // Ask Registrator to verify and add coin sale
            await registrator.askToVerifyIcoCreator(business.address, {from: businessWallet2});

            const event = registrator.AskToVerifyIcoCreator({_from:web3.eth.coinbase}, {fromBlock: 'latest'});
            const promise = new Promise(resolve => event.watch(async function(error, response) {

                // Check event arguments
                assert.equal(response.args.business, business.address, "Check business argument");
                assert.equal(response.args.icoCreator, businessWallet2, "Check icoCreator argument");

                // Create or find coin sale
                await registrator.createCoinSale({from: registratorAccount});
                const coinSalesCount = await registrator.coinSalesCount.call();
                const coinSale = CoinSale.at(await registrator.coinSales.call(coinSalesCount - 1));
                await coinSale.setIcoCreator(businessWallet2, {from: registratorAccount});
                await coinSale.setBusiness(business.address, {from: registratorAccount});

                // Call back
                await registrator.addVerifiedIcoCreator(business.address, businessWallet2, coinSale.address, {from: registratorAccount});
                assert.equal(await business.coinSalesCount.call(), 2, "Coin sale should be added");

                event.stopWatching();
                resolve();
            }));

            await promise;
        }

        // Coin sale #1 cannot be added again
        await expectThrow(registrator.askToVerifyIcoCreator(business.address, {from: businessWallet1}));

        // Coi sale #2 cannot be added again
        await expectThrow(registrator.askToVerifyIcoCreator(business.address, {from: businessWallet2}));

        // Coin sale can only be added by Registrator
        await expectThrow(business.addCoinSale(businessWallet3, {from: businessWallet3}));
    })

})