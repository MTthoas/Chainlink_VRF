// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Fundme {
    // Get the latest price of the ETH/USD price feed

    AggregatorV3Interface internal priceFeed;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function getThePrice() public view returns (int) {
        (, int price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function fund() public payable {
        // $50
        uint minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
    }

    function getConversionRate(uint ethAmount) public view returns (uint) {
        uint ethPrice = uint(getThePrice());
        uint ethAmountInUSD = (ethPrice * ethAmount) / 10 ** 18;
        return ethAmountInUSD;
    }

    function getVersion() public view returns (uint) {
        return priceFeed.version();
    }
}