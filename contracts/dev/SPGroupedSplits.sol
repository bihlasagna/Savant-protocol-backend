// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './SPSplit.sol';

/** 
  @member group The group indentifier.
  @member splits The splits to associate with the group.
*/
struct SPGroupedSplits {
  uint256 group;
  SPSplit[] splits;
}
