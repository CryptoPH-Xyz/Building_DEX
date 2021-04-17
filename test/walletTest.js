const Dex = artifacts.require("Dex")
const Xyz = artifacts.require("Xyz")
const truffleAssert = require('truffle-assertions')

contract ("Dex", accounts => {
    it("Only owner can add Tokens", async () => {
        let dex = await Dex.deployed()
        let xyz = await Xyz.deployed()
        await truffleAssert.passes(
            dex.addToken(web3.utils.fromUtf8("XYZ"), xyz.address, {from: accounts[0]})
        )
        await truffleAssert.reverts(
            dex.addToken(web3.utils.fromUtf8("AAVE"), xyz.address, {from: accounts[1]})
        )
    })

    it("should handle deposits correctly", async () => {
        let dex = await Dex.deployed()
        let xyz = await Xyz.deployed()
        await xyz.approve(dex.address, 500);
        await dex.deposit(100, web3.utils.fromUtf8("XYZ"))
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("XYZ"))
        assert.equal(balance.toNumber(), 100)
    })

    it("should handle faulty withdrawals correctly", async () => {
        let dex = await Dex.deployed()
        let xyz = await Xyz.deployed()
    //this should fail because initial deposit is 100 
        await truffleAssert.reverts(
            dex.withdraw(500, web3.utils.fromUtf8("XYZ"))
        )
    })

    it("should handle correct withdrawals correctly", async () => {
        let dex = await Dex.deployed()
        let xyz = await Xyz.deployed()
    //this should pass because initial deposit is 100      
        await truffleAssert.passes(
            dex.withdraw(100, web3.utils.fromUtf8("XYZ"))
        )
    })
    it("should deposit the correct amount of ETH", async () => {
        let dex = await Dex.deployed()
        await dex.depositEth({value: 1000});
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"))
        assert.equal(balance.toNumber(), 1000);
    })
    it("should withdraw the correct amount of ETH", async () => {
        let dex = await Dex.deployed()
        await dex.withdrawEth(1000);
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"))
        assert.equal(balance.toNumber(), 0);
    })
    it("should not allow over-withdrawing of ETH", async () => {
        let dex = await Dex.deployed()
        await truffleAssert.reverts(dex.withdrawEth(100));
    })
})

