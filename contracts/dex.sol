//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./wallet.sol";

contract Dex is Wallet {
    using SafeMath for uint256;

    enum Side {
        BUY,
        SELL
    }

    struct Order {
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
        uint filled;
    }

// counter for Order Ids
    uint public nextOrderId = 0;

    mapping(bytes32 => mapping(uint => Order[])) public orderBook;

    function getOrderBook(bytes32 ticker, Side side) public view returns(Order[] memory) {
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(bytes32 ticker, Side side, uint amount, uint price) public {
    //test 1 in dexTest.js
        if(side == Side.BUY){
            require(balances[msg.sender]["ETH"] >= amount.mul(price));
        }
    //test 2
        else if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount);
        }
    //Creating an Order
        Order[] storage orders = orderBook[ticker][uint(side)];
        orders.push(
            Order(nextOrderId, msg.sender, side, ticker, amount, price, 0)
        );
    //tests 3 & 4 
        //Bubble Sort
        uint i = orders.length > 0 ? orders.length - 1 : 0;

        if(side == Side.BUY){
            while(i > 0){
                if(orders[i - 1].price > orders[i].price){
                    break;
                }
                Order memory toSwap = orders[i - 1];
                orders[i - 1] = orders[i];
                orders[i] = toSwap;
                i--;
            }
        }
        else if(side == Side.SELL){
            while(i > 0){
                if(orders[i - 1].price < orders[i].price){
                    break;
                }
                Order memory toSwap = orders[i - 1];
                orders[i - 1] = orders[i];
                orders[i] = toSwap;
                i--;
            }
        }
        nextOrderId++; //create new order Id along with the new order
    }

    function createMarketOrder(Side side, bytes32 ticker, uint amount) public {
    //Verify is Seller has enough tokens to Sell
        if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount, "Insufficient Balance");
        }
        
        uint orderBookSide; 
        if (side == Side.BUY){
            orderBookSide = 1;
        }
        else {
            orderBookSide = 0;
        }
        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint totalFilled = 0;

        for(uint i = 0; i < orders.length && totalFilled < amount; i++){
            uint leftToFill = amount.sub(totalFilled); //amount = totalFilled
            uint availableToFill = orders[i].amount.sub(orders[i].filled); //orders.amount - orders.filled
            uint filled = 0;
            //How much we can fill from order[i]
            if(availableToFill > leftToFill){ //mawrket order will be 100% filled
                filled = leftToFill;
            }
            else { //availableToFill <= leftToFill, order[i] can only fill up to availableToFill
                filled = availableToFill;
            }
            //Update totalFilled;
            totalFilled = totalFilled.add(filled);
            orders[i].filled = orders[i].filled.add(filled);
            uint cost = filled.mul(orders[i].price);
            
        //Execute the trade & shift balances between buyer and seller
            
            if(side == Side.BUY) { 
            //Verify that the buyer has enough ETH to cover the purchase (require)
                require(balances[msg.sender]["ETH"] >= cost);

            //Transfer ETH from Buyer to Seller
                balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].sub(cost); //Reduce Buyer ETH balance
                balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].add(cost); //Seller gets ETH
            
            //Transfer tokens from Seller to Buyer
                balances[msg.sender][ticker] = balances[msg.sender][ticker].add(filled); //Buyer gets tokens
                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].sub(filled); //Seller gives tokens to buyer
                
            }
            else if(side ==Side.SELL){ //Reverse of a BUY order
            //Transfer ETH from Seller to Buyer
                balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].add(cost); 
                balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].sub(cost); 
            
            //Transfer tokens from Buyer to Seller
                balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(filled); 
                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].add(filled); 
            }
        }

    //Loop through the orderbook and remove orders that are 100% filled
        while(orders.length > 0 &&  orders[0].filled == orders[0].amount){ //1st order must be filled first before starting to fill next order
            //Remove the top element in the orders array by overwriting every element[i] with the next element[i+1]
            for(uint256 i = 0; i < orders.length - 1; i++){
                orders[i] = orders[i + 1];
            }
            orders.pop;
        }
    }
}

