// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './../enums/SPBallotState.sol';
import './../structs/SPFundingCycle.sol';
import './../structs/SPFundingCycleData.sol';

interface ISPFundingCycleStore {
  event Configure(
    uint256 indexed configuration,
    uint256 indexed projectId,
    SPFundingCycleData data,
    uint256 metadata,
    uint256 mustStartAtOrAfter,
    address caller
  );

  event Init(uint256 indexed configuration, uint256 indexed projectId, uint256 indexed basedOn);

  function latestConfigurationOf(uint256 _projectId) external view returns (uint256);

  function get(uint256 _projectId, uint256 _configuration)
    external
    view
    returns (SPFundingCycle memory);

  function latestConfiguredOf(uint256 _projectId)
    external
    view
    returns (SPFundingCycle memory fundingCycle, SPBallotState ballotState);

  function queuedOf(uint256 _projectId) external view returns (SPFundingCycle memory fundingCycle);

  function currentOf(uint256 _projectId) external view returns (SPFundingCycle memory fundingCycle);

  function currentBallotStateOf(uint256 _projectId) external view returns (SPBallotState);

  function configureFor(
    uint256 _projectId,
    SPFundingCycleData calldata _data,
    uint256 _metadata,
    uint256 _mustStartAtOrAfter
  ) external returns (SPFundingCycle memory fundingCycle);
}
