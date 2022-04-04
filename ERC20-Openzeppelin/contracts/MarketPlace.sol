// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract MarketPlace is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _orderIdCount;
    using EnumerableSet for EnumerableSet.AddressSet;
    struct Order {
        address seller;
        address buyer;
        uint256 tokenId;
        address paymentToken;
        uint256 price;
    }
    EnumerableSet.AddressSet private _supportedPaymentTokens;

    mapping(uint256 => Order) orders;
    event OrderAdded(
        uint256 indexed orderId,
        address indexed seller,
        uint256 indexed tokenId,
        address paymentToken,
        uint256 price
    );
    event OrderCancelled(uint256 indexed orderId);
    event OrderMatched(
        uint256 indexed orderId,
        address indexed seller,
        address indexed buyer,
        uint256 tokenId,
        address paymentToken,
        uint256 price
    );
    event FeeRateUpdate(uint256 feeDecimal, uint256 feeRate);

    constructor(
        address nftAddress_,
        uint256 feeDecimal_,
        uint256 feeRate_,
        address feeRecipient_
    ) {
        require(
            nftAddress_ != address(0),
            "NFTMarket place: nftAddress_ is zero address"
        );
        require(
            feeRecipient_ != address(0),
            "NFTMarket place: feeRecipient_ is zero address"
        );
        nftContract = IERC721(nftAddress_);
        feeRecipient = feeRecipient_;
        feeDecimal = feeDecimal_;
        feeRate = feeRate;
        _orderIdCount.increment();
    }

    function _updateFeeRecipient(address feeRecipient_) internal {
        require(
            feeRecipient_ != address(0),
            "NFTMarket place: feeRecipient_ is zero address"
        );
        feeRecipient = feeRecipient_;
    }

    function updateFeeRecipient(address feeRecipient_) external onlyOwner {
        require(
            feeRecipient_ != address(0),
            "NFTMarket place: feeRecipient_ is zero address"
        );
        feeRecipient = feeRecipient_;
    }

    function _updateFeeRate(uint256 feeDecimal_, uint256 feeRate_) internal {
        require(
            feeRate_ < 10**(feeDecimal_ + 2),
            "NFTMarket place: bad fee rate"
        );
        feeDecimal = feeDecimal_;
        feeRate = feeRate_;
        emit FeeRateUpdate(feeDecimal_, feeRate_);
    }

    function updateFeeRate(uint256 feeDecimal_, uint256 feeRate_) external onlyOwner {
        _updateFeeRate(feeDecimal_, feeRate_);
    }

    function _calculateFee(uint256 orderId_) private view returns (uint256) {
        Order storage _order = orders[orderId_];
        if (feeRate == 0) {
            return 0;
        }
        return (feeRate*_order.price) / 10**(feeDecimal + 2);
    }

    function isSeller(uint256 orderId_, address seller_) public view returns (bool) {
        return orders[orderId_].seller == seller_;
    }
}
