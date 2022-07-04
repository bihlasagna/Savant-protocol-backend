// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './../structs/SPGroupedSplits.sol';
import './../structs/SPSplit.sol';
import './ISPDirectory.sol';
import './ISPProjects.sol';

interface ISPSplitsStore {
  event SetSplit(
    uint256 indexed projectId,
    uint256 indexed domain,
    uint256 indexed group,
    SPSplit split,
    address caller
  );

  function projects() external view returns (ISPProjects);

  function directory() external view returns (ISPDirectory);

  function splitsOf(
    uint256 _projectId,
    uint256 _domain,
    uint256 _group
  ) external view returns (SPSplit[] memory);

  function set(
    uint256 _projectId,
    uint256 _domain,
    SPGroupedSplits[] memory _groupedSplits
  ) external;
}
