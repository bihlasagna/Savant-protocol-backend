// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface ISPMigratable {
  function prepForMigrationOf(uint256 _projectId, address _from) external;
}
