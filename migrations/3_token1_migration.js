const Xyz = artifacts.require("Xyz");
const Dex = artifacts.require("Dex");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Xyz);
};