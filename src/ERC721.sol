// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract MyNFT is ERC721, Ownable, VRFConsumerBaseV2 {
    uint256 private _totalMinted;
    uint256 public constant PRICE_IN_USD = 10; // 10 USD in 18 decimals

    AggregatorV3Interface internal priceFeed;

    // Chainklink VRF
    VRFCoordinatorV2Interface private COORDINATOR;
    uint64 private subscriptionId;
    bytes32 private keyHash;    
    uint32 private callbackGasLimit = 100000; 
    uint16 private requestConfirmations = 3;
    uint256 public randomResult;

    uint32 numWords = 1;
    mapping(uint256 => uint256) public nftPrices;

    event RequestedRandomness(uint64 requestId);

    constructor(uint64 _subscriptionId) 
        ERC721("MyNFT", "MNFT") 
        Ownable(msg.sender) 
        VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625) 
    {
        // ETH/USD price feed
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        COORDINATOR = VRFCoordinatorV2Interface(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
        subscriptionId = _subscriptionId; 
        keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    }

    // Request a random number for minting
    function requestRandomNumber() external {
        COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        emit RequestedRandomness(subscriptionId);
    }

    // Chainlink VRF callback function, the callback means the random number is ready
    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        randomResult = (randomWords[0] % 10) + 1;
  }

    // Get the latest price of ETH/USD
    function getThePrice() public view returns (int) {
        (, int price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    // Convert ETH to USD
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = uint256(getThePrice()); 
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 10 ** 8; // 8 decimals
        return ethAmountInUSD;
    }

    function mintNFT() public payable {
        uint256 ethPrice = uint256(getThePrice());
        // require(ethPrice > 0, "Invalid ETH price from Chainlink");

        uint256 priceInETH = (PRICE_IN_USD * 10 ** 18) / ethPrice;
        require(msg.value >= priceInETH, "Insufficient ETH to mint NFT");

        _totalMinted += 1;
        uint256 tokenId = totalSupply() + 1;

        // Get a random price for the NFT, call requestRandomNumber

        require(randomResult > 0, "Random number not ready");
        uint256 randomPriceInUSD = randomResult * 10 ** 18; // 18 decimals

        nftPrices[tokenId] = randomPriceInUSD;    
        _safeMint(msg.sender, tokenId);

        // Refund excess payment
        if (msg.value > priceInETH) {
            payable(msg.sender).transfer(msg.value - priceInETH);
        }
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function withdraw() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    function getNFTPrice(uint256 tokenId) public view returns (uint256) {
        return nftPrices[tokenId];
    }

    function totalSupply() public view returns (uint256) {
        return _totalMinted;
    }
}
