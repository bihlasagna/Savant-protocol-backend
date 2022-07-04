// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface ISPPriceFeed {
  function currentPrice(uint256 _targetDecimals) external view returns (uint256);
}
