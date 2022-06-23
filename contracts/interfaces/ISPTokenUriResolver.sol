// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface ISPTokenUriResolver {
  function getUri(uint256 _projectId) external view returns (string memory tokenUri);
}
