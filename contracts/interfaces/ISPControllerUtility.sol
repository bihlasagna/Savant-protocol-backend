// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './ISPDirectory.sol';

interface ISPControllerUtility {
  function directory() external view returns (IJBDirectory);
}
