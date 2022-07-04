// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './../structs/SPFundingCycle.sol';
import './../structs/SPTokenAmount.sol';
import './ISPDirectory.sol';
import './ISPFundingCycleStore.sol';
import './ISPPayDelegate.sol';
import './ISPPrices.sol';
import './ISPRedemptionDelegate.sol';
import './ISPSingleTokenPaymentTerminal.sol';

interface ISPSingleTokenPaymentTerminalStore {
  function fundingCycleStore() external view returns (ISPFundingCycleStore);

  function directory() external view returns (ISPDirectory);

  function prices() external view returns (ISPPrices);

  function balanceOf(ISPSingleTokenPaymentTerminal _terminal, uint256 _projectId)
    external
    view
    returns (uint256);

  function usedDistributionLimitOf(
    ISPSingleTokenPaymentTerminal _terminal,
    uint256 _projectId,
    uint256 _fundingCycleNumber
  ) external view returns (uint256);

  function usedOverflowAllowanceOf(
    ISPSingleTokenPaymentTerminal _terminal,
    uint256 _projectId,
    uint256 _fundingCycleConfiguration
  ) external view returns (uint256);

  function currentOverflowOf(ISPSingleTokenPaymentTerminal _terminal, uint256 _projectId)
    external
    view
    returns (uint256);

  function currentTotalOverflowOf(
    uint256 _projectId,
    uint256 _decimals,
    uint256 _currency
  ) external view returns (uint256);

  function currentReclaimableOverflowOf(
    ISPSingleTokenPaymentTerminal _terminal,
    uint256 _projectId,
    uint256 _tokenCount,
    bool _useTotalOverflow
  ) external view returns (uint256);

  function currentReclaimableOverflowOf(
    uint256 _projectId,
    uint256 _tokenCount,
    uint256 _totalSupply,
    uint256 _overflow
  ) external view returns (uint256);

  function recordPaymentFrom(
    address _payer,
    SPTokenAmount memory _amount,
    uint256 _projectId,
    uint256 _baseWeightCurrency,
    address _beneficiary,
    string calldata _memo,
    bytes calldata _metadata
  )
    external
    returns (
      SPFundingCycle memory fundingCycle,
      uint256 tokenCount,
      ISPPayDelegate delegate,
      string memory memo
    );

  function recordRedemptionFor(
    address _holder,
    uint256 _projectId,
    uint256 _tokenCount,
    string calldata _memo,
    bytes calldata _metadata
  )
    external
    returns (
      SPFundingCycle memory fundingCycle,
      uint256 reclaimAmount,
      ISPRedemptionDelegate delegate,
      string memory memo
    );

  function recordDistributionFor(
    uint256 _projectId,
    uint256 _amount,
    uint256 _currency
  ) external returns (SPFundingCycle memory fundingCycle, uint256 distributedAmount);

  function recordUsedAllowanceOf(
    uint256 _projectId,
    uint256 _amount,
    uint256 _currency
  ) external returns (SPFundingCycle memory fundingCycle, uint256 withdrawnAmount);

  function recordAddedBalanceFor(uint256 _projectId, uint256 _amount) external;

  function recordMigration(uint256 _projectId) external returns (uint256 balance);
}
