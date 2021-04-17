//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is Ownable {
    using SafeMath for uint256;

    struct Token{
        bytes32 ticker;
        address tokenAddress;
    }

    mapping(bytes32 => Token) public tokenMapping;
    bytes32[] public tokenList;

//address to tokens owned to balances of each token
    mapping (address => mapping(bytes32 => uint256)) public balances;

    modifier tokenExist(bytes32 _ticker){
        require(tokenMapping[_ticker].tokenAddress != address(0), "Token not Found");
        _;
    }

//adds new tokens using ticker and address in mapping
//add the ticker in the token list
//only owner can add tokens
    function addToken(bytes32 _ticker, address _tokenAddress) external onlyOwner {
        tokenMapping[_ticker] = Token(_ticker, _tokenAddress);
        tokenList.push(_ticker);
    }

//use IERC20 Interface
//require that the token exists (not equal to an uninititalized address) - use modifier
//adjust the balances of msg.sender use SafeMath
//deposit from msg.sender to this contract
    function deposit(uint _amount, bytes32 _ticker) tokenExist(_ticker) external {
        //checks using tokenExist modifier
        balances[msg.sender][_ticker] = balances[msg.sender][_ticker].add(_amount); //effects
        IERC20(tokenMapping[_ticker].tokenAddress).transferFrom(msg.sender, address(this), _amount); //interactions
    }

//use IERC20 Interface
//require that the token exists (not equal to an uninititalized address) - use modifier
//require that msg.sender has a balance on the token to withdraw
//adjust the balances of msg.sender use SafeMath
//transfer from us(this contract) to msg.sender(rightful owner)
    function withdraw(uint _amount, bytes32 _ticker) tokenExist(_ticker) external {
        //checks using tokenExist modifier
        require(balances[msg.sender][_ticker] >= _amount, "Insufficient Balance");
        balances[msg.sender][_ticker] = balances[msg.sender][_ticker].sub(_amount);
        IERC20(tokenMapping[_ticker].tokenAddress).transfer(msg.sender, _amount);
    }
    
    function depositEth() payable external {
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].add(msg.value);
    }
    
    function withdrawEth(uint _amount) external {
        require(balances[msg.sender][bytes32("ETH")] >= _amount,'Insuffient balance'); 
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].sub(_amount);
        msg.sender.call{value: _amount}("");
    }


}   
