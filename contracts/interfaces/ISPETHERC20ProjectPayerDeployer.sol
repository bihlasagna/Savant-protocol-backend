// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './ISPDirectory.sol';
import './ISPProjectPayer.sol';

interface ISPETHERC20ProjectPayerDeployer {
  event DeployProjectPayer(
    ISPProjectPayer indexed projectPayer,
    uint256 defaultProjectId,
    address defaultBeneficiary,
    bool defaultPreferClaimedTokens,
    string defaultMemo,
    bytes defaultMetadata,
    bool preferAddToBalance,
    ISPDirectory directory,
    address owner,
    address caller
  );

  function deployProjectPayer(
    uint256 _defaultProjectId,
    address payable _defaultBeneficiary,
    bool _defaultPreferClaimedTokens,
    string memory _defaultMemo,
    bytes memory _defaultMetadata,
    bool _preferAddToBalance,
    ISPDirectory _directory,
    address _owner
  ) external returns (ISPProjectPayer projectPayer);
}
