// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import './../structs/SPSplit.sol';
import './ISPSplitsStore.sol';

interface ISPSplitsPayer is IERC165 {
  event SetDefaultSplits(
    uint256 indexed projectId,
    uint256 indexed domain,
    uint256 indexed group,
    address caller
  );
  event Pay(
    uint256 indexed projectId,
    address beneficiary,
    address token,
    uint256 amount,
    uint256 decimals,
    uint256 leftoverAmount,
    uint256 minReturnedTokens,
    bool preferClaimedTokens,
    string memo,
    bytes metadata,
    address caller
  );

  event AddToBalance(
    uint256 indexed projectId,
    address beneficiary,
    address token,
    uint256 amount,
    uint256 decimals,
    uint256 leftoverAmount,
    string memo,
    bytes metadata,
    address caller
  );

  event DistributeToSplit(
    uint256 indexed projectId,
    uint256 indexed domain,
    uint256 indexed group,
    SPSplit split,
    uint256 amount,
    address defaultBeneficiary,
    address caller
  );

  function defaultSplitsProjectId() external view returns (uint256);

  function defaultSplitsDomain() external view returns (uint256);

  function defaultSplitsGroup() external view returns (uint256);

  function splitsStore() external view returns (ISPSplitsStore);

  function setDefaultSplits(
    uint256 _projectId,
    uint256 _domain,
    uint256 _group
  ) external;
}
