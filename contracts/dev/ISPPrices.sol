// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './ISPPriceFeed.sol';

interface ISPPrices {
  event AddFeed(uint256 indexed currency, uint256 indexed base, ISPPriceFeed feed);

  function feedFor(uint256 _currency, uint256 _base) external view returns (ISPPriceFeed);

  function priceFor(
    uint256 _currency,
    uint256 _base,
    uint256 _decimals
  ) external view returns (uint256);

  function addFeedFor(
    uint256 _currency,
    uint256 _base,
    ISPPriceFeed _priceFeed
  ) external;
}
