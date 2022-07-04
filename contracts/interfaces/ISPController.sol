// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import './../structs/SPFundAccessConstraints.sol';
import './../structs/SPFundingCycleData.sol';
import './../structs/SPFundingCycleMetadata.sol';
import './../structs/SPGroupedSplits.sol';
import './../structs/SPProjectMetadata.sol';
import './ISPDirectory.sol';
import './ISPFundingCycleStore.sol';
import './ISPMigratable.sol';
import './ISPPaymentTerminal.sol';
import './ISPSplitsStore.sol';
import './ISPToken.sol';
import './ISPTokenStore.sol';

interface ISPController is IERC165 {
  event LaunchProject(uint256 configuration, uint256 projectId, string memo, address caller);

  event LaunchFundingCycles(uint256 configuration, uint256 projectId, string memo, address caller);

  event ReconfigureFundingCycles(
    uint256 configuration,
    uint256 projectId,
    string memo,
    address caller
  );

  event SetFundAccessConstraints(
    uint256 indexed fundingCycleConfiguration,
    uint256 indexed fundingCycleNumber,
    uint256 indexed projectId,
    SPFundAccessConstraints constraints,
    address caller
  );

  event DistributeReservedTokens(
    uint256 indexed fundingCycleConfiguration,
    uint256 indexed fundingCycleNumber,
    uint256 indexed projectId,
    address beneficiary,
    uint256 tokenCount,
    uint256 beneficiaryTokenCount,
    string memo,
    address caller
  );

  event DistributeToReservedTokenSplit(
    uint256 indexed projectId,
    uint256 indexed domain,
    uint256 indexed group,
    SPSplit split,
    uint256 tokenCount,
    address caller
  );

  event MintTokens(
    address indexed beneficiary,
    uint256 indexed projectId,
    uint256 tokenCount,
    uint256 beneficiaryTokenCount,
    string memo,
    uint256 reservedRate,
    address caller
  );

  event BurnTokens(
    address indexed holder,
    uint256 indexed projectId,
    uint256 tokenCount,
    string memo,
    address caller
  );

  event Migrate(uint256 indexed projectId, ISPMigratable to, address caller);

  event PrepMigration(uint256 indexed projectId, address from, address caller);

  function projects() external view returns (ISPProjects);

  function fundingCycleStore() external view returns (ISPFundingCycleStore);

  function tokenStore() external view returns (ISPTokenStore);

  function splitsStore() external view returns (ISPSplitsStore);

  function directory() external view returns (ISPDirectory);

  function reservedTokenBalanceOf(uint256 _projectId, uint256 _reservedRate)
    external
    view
    returns (uint256);

  function distributionLimitOf(
    uint256 _projectId,
    uint256 _configuration,
    ISPPaymentTerminal _terminal,
    address _token
  ) external view returns (uint256 distributionLimit, uint256 distributionLimitCurrency);

  function overflowAllowanceOf(
    uint256 _projectId,
    uint256 _configuration,
    ISPPaymentTerminal _terminal,
    address _token
  ) external view returns (uint256 overflowAllowance, uint256 overflowAllowanceCurrency);

  function totalOutstandingTokensOf(uint256 _projectId, uint256 _reservedRate)
    external
    view
    returns (uint256);

  function getFundingCycleOf(uint256 _projectId, uint256 _configuration)
    external
    view
    returns (SPFundingCycle memory fundingCycle, SPFundingCycleMetadata memory metadata);

  function latestConfiguredFundingCycleOf(uint256 _projectId)
    external
    view
    returns (
      SPFundingCycle memory,
      SPFundingCycleMetadata memory metadata,
      SPBallotState
    );

  function currentFundingCycleOf(uint256 _projectId)
    external
    view
    returns (SPFundingCycle memory fundingCycle, SPFundingCycleMetadata memory metadata);

  function queuedFundingCycleOf(uint256 _projectId)
    external
    view
    returns (SPFundingCycle memory fundingCycle, SPFundingCycleMetadata memory metadata);

  function launchProjectFor(
    address _owner,
    SPProjectMetadata calldata _projectMetadata,
    SPFundingCycleData calldata _data,
    SPFundingCycleMetadata calldata _metadata,
    uint256 _mustStartAtOrAfter,
    SPGroupedSplits[] memory _groupedSplits,
    SPFundAccessConstraints[] memory _fundAccessConstraints,
    ISPPaymentTerminal[] memory _terminals,
    string calldata _memo
  ) external returns (uint256 projectId);

  function launchFundingCyclesFor(
    uint256 _projectId,
    SPFundingCycleData calldata _data,
    SPFundingCycleMetadata calldata _metadata,
    uint256 _mustStartAtOrAfter,
    SPGroupedSplits[] memory _groupedSplits,
    SPFundAccessConstraints[] memory _fundAccessConstraints,
    ISPPaymentTerminal[] memory _terminals,
    string calldata _memo
  ) external returns (uint256 configuration);

  function reconfigureFundingCyclesOf(
    uint256 _projectId,
    SPFundingCycleData calldata _data,
    SPFundingCycleMetadata calldata _metadata,
    uint256 _mustStartAtOrAfter,
    SPGroupedSplits[] memory _groupedSplits,
    SPFundAccessConstraints[] memory _fundAccessConstraints,
    string calldata _memo
  ) external returns (uint256);

  function issueTokenFor(
    uint256 _projectId,
    string calldata _name,
    string calldata _symbol
  ) external returns (ISPToken token);

  function changeTokenOf(
    uint256 _projectId,
    ISPToken _token,
    address _newOwner
  ) external;

  function mintTokensOf(
    uint256 _projectId,
    uint256 _tokenCount,
    address _beneficiary,
    string calldata _memo,
    bool _preferClaimedTokens,
    bool _useReservedRate
  ) external returns (uint256 beneficiaryTokenCount);

  function burnTokensOf(
    address _holder,
    uint256 _projectId,
    uint256 _tokenCount,
    string calldata _memo,
    bool _preferClaimedTokens
  ) external;

  function distributeReservedTokensOf(uint256 _projectId, string memory _memo)
    external
    returns (uint256);

  function migrate(uint256 _projectId, ISPMigratable _to) external;
}
