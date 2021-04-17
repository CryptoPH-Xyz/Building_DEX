const Dex = artifacts.require("Dex")
const Xyz = artifacts.require("Xyz")
const truffleAssert = require('truffle-assertions')


contract("Dex", accounts => {

//Limit Order Tests
    // The user must have ETH deposited such that ETH deposited >= BUY order value
    it("should only allow BUY orders <= deposited ETH", async () =>{
        let dex = await Dex.deployed()
        await truffleAssert.reverts(
            dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 0, 10, 1) //Requires 10 ETH, ETH balance is 0
        )
        
        dex.depositEth({value: 10}) //ETH balance is now 10
        await truffleAssert.passes(
            dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 0, 10, 1) 
        )
    })

    // The user must have enough deposited tokens such that token balance >= SELL order amount
    it("amount of token to SELL should be <= amount of same token in balances", async () =>{
        let dex = await Dex.deployed()
        let xyz = await Xyz.deployed()
        await truffleAssert.reverts(
            dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 1, 10, 1) //selling 10 tokens
        )
        await dex.addToken(web3.utils.fromUtf8("XYZ"), xyz.address, {from: accounts[0]})
        await xyz.approve(dex.address, 500);
        await dex.deposit(10, web3.utils.fromUtf8("XYZ"));
        await truffleAssert.passes(
            dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 1, 10, 1) //selling 10 tokens
        )
       
    })
    // The BUY order book should be ordered in price from highest to lowest starting with index 0
    it("The BUY order book should be ordered in price from highest to lowest starting with index 0", async () =>{
        let dex = await Dex.deployed()
        let xyz = await Xyz.deployed()
        
        await xyz.approve(dex.address, 500);
    // create a BUY order book
        await dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 0, 1, 50)  // 50 ETH index 0
        await dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 0, 10, 20) // 200 ETH index 1 (should be 2)
        await dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 0, 10, 30) // 300 ETH index 2 (should be 1)
        await dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 0, 5, 10) // 50 ETH index 3
         
        let buyOrderBook = await dex.getOrderBook(web3.utils.fromUtf8("XYZ"), 0)
        assert(buyOrderBook.length > 0);

        for(let i = 0; i < buyOrderBook.length - 1; i++){ 
            assert(buyOrderBook[i] >= buyOrderBook[i + 1], "BUY Orders not Sorted")
        }
    })

//Additional tests
    // The SELL order book should be ordered in price from lowest to highest starting with index 0
    it("The SELL order book should be ordered in price from lowest to highest starting with index 0", async () =>{
        let dex = await Dex.deployed()
        let xyz = await Xyz.deployed()
        
        await xyz.approve(dex.address, 500);
    // create a SELL order book
        await dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 1, 1, 50)  // 50 ETH index 0 (should be 3)
        await dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 1, 10, 20) // 200 ETH index 1 
        await dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 1, 10, 30) // 300 ETH index 2 
        await dex.createLimitOrder(web3.utils.fromUtf8("XYZ"), 1, 5, 10) // 50 ETH index 3 (should be 0)
     
        let sellOrderBook = await dex.getOrderBook(web3.utils.fromUtf8("XYZ"), 1)
        assert(sellOrderBook.length > 0)  

        for(let i = 0; i < sellOrderBook.length - 1; i++){ 
            assert(sellOrderBook[i] <= sellOrderBook[i + 1], "SELL Orders not Sorted")
        }
    })
})