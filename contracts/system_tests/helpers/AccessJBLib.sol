// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '../../libraries/SPCurrencies.sol';
import '../../libraries/SPConstants.sol';
import '../../libraries/SPTokens.sol';

contract AccessSPLib {
  function ETH() external pure returns (uint256) {
    return SPCurrencies.ETH;
  }

  function USD() external pure returns (uint256) {
    return SPCurrencies.USD;
  }

  function ETHToken() external pure returns (address) {
    return SPTokens.ETH;
  }

  function MAX_FEE() external pure returns (uint256) {
    return SPConstants.MAX_FEE;
  }

  function MAX_RESERVED_RATE() external pure returns (uint256) {
    return SPConstants.MAX_RESERVED_RATE;
  }

  function MAX_REDEMPTION_RATE() external pure returns (uint256) {
    return SPConstants.MAX_REDEMPTION_RATE;
  }

  function MAX_DISCOUNT_RATE() external pure returns (uint256) {
    return SPConstants.MAX_DISCOUNT_RATE;
  }

  function SPLITS_TOTAL_PERCENT() external pure returns (uint256) {
    return SPConstants.SPLITS_TOTAL_PERCENT;
  }

  function MAX_FEE_DISCOUNT() external pure returns (uint256) {
    return SPConstants.MAX_FEE_DISCOUNT;
  }
}
