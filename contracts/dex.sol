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
        bytes32 ticker;
        uint amount;
        uint price;
    }

    mapping(bytes32 => mapping(uint => Order[])) public OrderBook;

// traders should deposit ETH to buy Tokens
    mapping(address => uint256) public balanceETH;

    function depositETH(uint256 _amount) public payable{
        balanceETH[msg.sender] = balanceETH[msg.sender].add(_amount);
    }

    function getBalanceETH() public view returns(uint256){
        return balanceETH[msg.sender];
    }

    function getOrderBook(bytes32 _ticker, Side _side) public view returns(Order[] memory) {
        return OrderBook[_ticker][uint(_side)];
    }

// Complex function to create
    function createLimitOrder(bytes32 _ticker, Side _side, uint _amount, uint _price) public {

    }     
}

