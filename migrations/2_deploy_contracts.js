var Registrator = artifacts.require("./Registrator.sol");

module.exports = function(deployer) {
    deployer.deploy(Registrator);
};
