// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './ISPPaymentTerminal.sol';

interface ISPSingleTokenPaymentTerminal is ISPPaymentTerminal {
  function token() external view returns (address);

  function currency() external view returns (uint256);

  function decimals() external view returns (uint256);
}
