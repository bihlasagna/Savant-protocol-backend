// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './ISPFundingCycleBallot.sol';

interface ISPReconfigurationBufferBallot is ISPFundingCycleBallot {
  event Finalize(
    uint256 indexed projectId,
    uint256 indexed configuration,
    SPBallotState indexed ballotState,
    address caller
  );

  function finalState(uint256 _projectId, uint256 _configuration)
    external
    view
    returns (SPBallotState);

  function fundingCycleStore() external view returns (ISPFundingCycleStore);

  function finalize(uint256 _projectId, uint256 _configured) external returns (SPBallotState);
}
