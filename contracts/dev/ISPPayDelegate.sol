// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import './../structs/SPDidPayData.sol';

/**
  @title
  Pay delegate

  @notice
  Delegate called after SPTerminal.pay(..) logic completion (if passed by the funding cycle datasource)

  @dev
  Adheres to:
  IERC165 for adequate interface integration
*/
interface ISPPayDelegate is IERC165 {
  /**
    @notice
    This function is called by SPPaymentTerminal.pay(..), after the execution of its logic

    @dev
    Critical business logic should be protected by an appropriate access control
    
    @param _data the data passed by the terminal, as a SPDidPayData struct:
                  address payer;
                  uint256 projectId;
                  uint256 currentFundingCycleConfiguration;
                  SPTokenAmount amount;
                  uint256 projectTokenCount;
                  address beneficiary;
                  bool preferClaimedTokens;
                  string memo;
                  bytes metadata;
  */
  function didPay(SPDidPayData calldata _data) external;
}
