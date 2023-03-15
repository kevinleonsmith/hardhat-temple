// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CallOptionExchange {
    AggregatorV3Interface public priceFeed;
    uint256 public strikePrice;
    uint256 public expirationTime;
    address public seller;
    
    constructor(address _priceFeed, uint256 _strikePrice, uint256 _expirationTime) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        strikePrice = _strikePrice;
        expirationTime = _expirationTime;
        seller = msg.sender;
    }
    
    function sell() external {
        require(msg.sender == seller, "Only seller can sell the option");
        require(block.timestamp < expirationTime, "Option has expired");
        uint256 currentPrice = getCurrentPrice();
        require(currentPrice >= strikePrice, "Option is out-of-the-money");
        uint256 profit = currentPrice - strikePrice;
        payable(msg.sender).transfer(profit);
    }
    
    function getCurrentPrice() public view returns (uint256) {
        (,int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed");
        return uint256(price);
    }
}