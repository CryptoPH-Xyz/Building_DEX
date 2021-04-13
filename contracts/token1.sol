//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Xyz is ERC20 {
    constructor() ERC20("Future", "XYZ") {
        _mint(msg.sender, 10000);
    }
}