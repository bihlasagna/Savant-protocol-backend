// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import './../structs/SPDidRedeemData.sol';

/**
  @title
  Redemption delegate

  @notice
  Delegate called after SPTerminal.redeemTokensOf(..) logic completion (if passed by the funding cycle datasource)

  @dev
  Adheres to:
  IERC165 for adequate interface integration
*/
interface ISPRedemptionDelegate is IERC165 {
    /**
    @notice
    This function is called by SPPaymentTerminal.redeemTokensOf(..), after the execution of its logic

    @dev
    Critical business logic should be protected by an appropriate access control
    
    @param _data the data passed by the terminal, as a SPDidRedeemData struct:
                address holder;
                uint256 projectId;
                uint256 currentFundingCycleConfiguration;
                uint256 projectTokenCount;
                SPTokenAmount reclaimedAmount;
                address payable beneficiary;
                string memo;
                bytes metadata;
  */
  function didRedeem(SPDidRedeemData calldata _data) external;
}
