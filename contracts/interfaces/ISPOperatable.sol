// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './ISPOperatorStore.sol';

interface ISPOperatable {
  function operatorStore() external view returns (ISPOperatorStore);
}
