//import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import expectThrow from './Helpers/expectThrow';

var Registrator = artifacts.require("./Registrator.sol");
var Customer = artifacts.require("./Customer.sol");
var Business = artifacts.require("./Business.sol");
var Search = artifacts.require("./Search.sol");
var CoinSale = artifacts.require("./CoinSale.sol");
var Offer = artifacts.require("./Offer.sol");
var TestToken = artifacts.require("./TestToken.sol");

contract('Search', function([_, registratorAccount, customerAccount, businessAccount, searchAccount]) {

    it("should create Search", async function() {

        const tokenContract = await TestToken.new();
        await tokenContract.mint(businessAccount, 1000);
        await tokenContract.finishMinting();

        //

        var registrator = await Registrator.new({from: registratorAccount});

        await registrator.createCustomer({from: customerAccount});
        const customersCount = await registrator.customersCount.call();
        const customer = Customer.at(await registrator.customers.call(customersCount - 1));

        await registrator.createBusiness({from: businessAccount});
        const businessesCount = await registrator.businessesCount.call();
        const business = Business.at(await registrator.businesses.call(businessesCount - 1));

        await registrator.createCoinSale({from: registratorAccount});
        const coinSalesCount = await registrator.coinSalesCount.call();
        const coinSale = CoinSale.at(await registrator.coinSales.call(coinSalesCount - 1));
        await business.addCoinSale(coinSale.address, {from: registratorAccount});
        await coinSale.setBusiness(business.address, {from: registratorAccount});

        await registrator.createSearch({from: searchAccount});
        const searchesCount = await registrator.searchesCount.call();
        const search = Search.at(await registrator.searches.call(searchesCount - 1));

        await business.createOffer(coinSale.address, tokenContract.address, 100, {from: businessAccount});
        const offersCount = await business.offersCount.call();
        const offer = Offer.at(await business.offers.call(offersCount - 1));
        await offer.addSearch(search.address, {from: businessAccount}); // Business allowed concrete Search to show Offer

        //

        assert.equal(await tokenContract.balanceOf.call(businessAccount), 1000, "Check Business balance");
        assert.equal(await tokenContract.balanceOf.call(offer.address), 0, "Check Offer balance");
        assert.equal(await tokenContract.balanceOf.call(customerAccount), 0, "Check Customer balance");
        assert.equal(await tokenContract.balanceOf.call(searchAccount), 0, "Check Search balance");

        await tokenContract.transfer(offer.address, 100, {from: businessAccount});

        assert.equal(await tokenContract.balanceOf.call(businessAccount), 900, "Check Business balance");
        assert.equal(await tokenContract.balanceOf.call(offer.address), 100, "Check Offer balance");
        assert.equal(await tokenContract.balanceOf.call(customerAccount), 0, "Check Customer balance");
        assert.equal(await tokenContract.balanceOf.call(searchAccount), 0, "Check Search balance");

        await search.showOfferToCustomer(offer.address, customer.address, {from: searchAccount});

        assert.equal(await tokenContract.balanceOf.call(businessAccount), 900, "Check Business balance");
        assert.equal(await tokenContract.balanceOf.call(offer.address), 0, "Check Offer balance");
        assert.equal(await tokenContract.balanceOf.call(customerAccount), 50, "Check Customer balance");
        assert.equal(await tokenContract.balanceOf.call(searchAccount), 50, "Check Search balance");
    })

})