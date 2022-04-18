 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSale {
    uint256 public investorMinCap = 0.02 ether;
    uint256 public investorHardCap = 10 ether;
    uint256 public rate = 10;
    mapping(address => uint256) public contributions;
    IERC20 public token;

    constructor(address _tokenAddres) {
        token = IERC20(_tokenAddres);
    }

    function buy() public payable {
        uint256 amountToken = msg.value * rate;

        require(msg.value > investorMinCap, "TokenSale: not reached min cap");
        require(contributions[msg.sender] + amountToken < investorMinCap, "TokenSale: exceeds hard cap");
        require(token.balanceOf(address(this)) > amountToken, "TokenSale: exceeds token balance");

        contributions[msg.sender] += msg.value;
        token.transfer(msg.sender, amountToken);
    }
}