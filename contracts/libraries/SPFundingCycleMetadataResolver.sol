// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './../interfaces/ISPFundingCycleDataSource.sol';
import './../structs/SPFundingCycleMetadata.sol';
import './../structs/SPGlobalFundingCycleMetadata.sol';
import './SPConstants.sol';
import './SPGlobalFundingCycleMetadataResolver.sol';

library SPFundingCycleMetadataResolver {
  function global(SPFundingCycle memory _fundingCycle)
    internal
    pure
    returns (SPGlobalFundingCycleMetadata memory metadata)
  {
    return SPGlobalFundingCycleMetadataResolver.expandMetadata(uint8(_fundingCycle.metadata >> 8));
  }

  function reservedRate(SPFundingCycle memory _fundingCycle) internal pure returns (uint256) {
    return uint256(uint16(_fundingCycle.metadata >> 24));
  }

  function redemptionRate(SPFundingCycle memory _fundingCycle) internal pure returns (uint256) {
    // Redemption rate is a number 0-10000. It's inverse was stored so the most common case of 100% results in no storage needs.
    return SPConstants.MAX_REDEMPTION_RATE - uint256(uint16(_fundingCycle.metadata >> 40));
  }

  function ballotRedemptionRate(SPFundingCycle memory _fundingCycle)
    internal
    pure
    returns (uint256)
  {
    // Redemption rate is a number 0-10000. It's inverse was stored so the most common case of 100% results in no storage needs.
    return SPConstants.MAX_REDEMPTION_RATE - uint256(uint16(_fundingCycle.metadata >> 56));
  }

  function payPaused(SPFundingCycle memory _fundingCycle) internal pure returns (bool) {
    return ((_fundingCycle.metadata >> 72) & 1) == 1;
  }

  function distributionsPaused(SPFundingCycle memory _fundingCycle) internal pure returns (bool) {
    return ((_fundingCycle.metadata >> 73) & 1) == 1;
  }

  function redeemPaused(SPFundingCycle memory _fundingCycle) internal pure returns (bool) {
    return ((_fundingCycle.metadata >> 74) & 1) == 1;
  }

  function burnPaused(SPFundingCycle memory _fundingCycle) internal pure returns (bool) {
    return ((_fundingCycle.metadata >> 75) & 1) == 1;
  }

  function mintingAllowed(SPFundingCycle memory _fundingCycle) internal pure returns (bool) {
    return ((_fundingCycle.metadata >> 76) & 1) == 1;
  }

  function changeTokenAllowed(SPFundingCycle memory _fundingCycle) internal pure returns (bool) {
    return ((_fundingCycle.metadata >> 77) & 1) == 1;
  }

  function terminalMigrationAllowed(SPFundingCycle memory _fundingCycle)
    internal
    pure
    returns (bool)
  {
    return ((_fundingCycle.metadata >> 78) & 1) == 1;
  }

  function controllerMigrationAllowed(SPFundingCycle memory _fundingCycle)
    internal
    pure
    returns (bool)
  {
    return ((_fundingCycle.metadata >> 79) & 1) == 1;
  }

  function shouldHoldFees(SPFundingCycle memory _fundingCycle) internal pure returns (bool) {
    return ((_fundingCycle.metadata >> 80) & 1) == 1;
  }

  function useTotalOverflowForRedemptions(SPFundingCycle memory _fundingCycle)
    internal
    pure
    returns (bool)
  {
    return ((_fundingCycle.metadata >> 81) & 1) == 1;
  }

  function useDataSourceForPay(SPFundingCycle memory _fundingCycle) internal pure returns (bool) {
    return (_fundingCycle.metadata >> 82) & 1 == 1;
  }

  function useDataSourceForRedeem(SPFundingCycle memory _fundingCycle)
    internal
    pure
    returns (bool)
  {
    return (_fundingCycle.metadata >> 83) & 1 == 1;
  }

  function dataSource(SPFundingCycle memory _fundingCycle) internal pure returns (address) {
    return address(uint160(_fundingCycle.metadata >> 84));
  }

  /**
    @notice
    Pack the funding cycle metadata.

    @param _metadata The metadata to validate and pack.

    @return packed The packed uint256 of all metadata params. The first 8 bits specify the version.
  */
  function packFundingCycleMetadata(SPFundingCycleMetadata memory _metadata)
    internal
    pure
    returns (uint256 packed)
  {
    // version 1 in the bits 0-7 (8 bits).
    packed = 1;
    // global metadta in bits 8-23 (16 bits).
    packed |=
      SPGlobalFundingCycleMetadataResolver.packFundingCycleGlobalMetadata(_metadata.global) <<
      8;
    // reserved rate in bits 24-39 (16 bits).
    packed |= _metadata.reservedRate << 24;
    // redemption rate in bits 40-55 (16 bits).
    // redemption rate is a number 0-10000. Store the reverse so the most common case of 100% results in no storage needs.
    packed |= (SPConstants.MAX_REDEMPTION_RATE - _metadata.redemptionRate) << 40;
    // ballot redemption rate rate in bits 56-71 (16 bits).
    // ballot redemption rate is a number 0-10000. Store the reverse so the most common case of 100% results in no storage needs.
    packed |= (SPConstants.MAX_REDEMPTION_RATE - _metadata.ballotRedemptionRate) << 56;
    // pause pay in bit 72.
    if (_metadata.pausePay) packed |= 1 << 72;
    // pause tap in bit 73.
    if (_metadata.pauseDistributions) packed |= 1 << 73;
    // pause redeem in bit 74.
    if (_metadata.pauseRedeem) packed |= 1 << 74;
    // pause burn in bit 75.
    if (_metadata.pauseBurn) packed |= 1 << 75;
    // allow minting in bit 76.
    if (_metadata.allowMinting) packed |= 1 << 76;
    // allow change token in bit 77.
    if (_metadata.allowChangeToken) packed |= 1 << 77;
    // allow terminal migration in bit 78.
    if (_metadata.allowTerminalMigration) packed |= 1 << 78;
    // allow controller migration in bit 79.
    if (_metadata.allowControllerMigration) packed |= 1 << 79;
    // hold fees in bit 80.
    if (_metadata.holdFees) packed |= 1 << 80;
    // useTotalOverflowForRedemptions in bit 81.
    if (_metadata.useTotalOverflowForRedemptions) packed |= 1 << 81;
    // use pay data source in bit 82.
    if (_metadata.useDataSourceForPay) packed |= 1 << 82;
    // use redeem data source in bit 83.
    if (_metadata.useDataSourceForRedeem) packed |= 1 << 83;
    // data source address in bits 84-243.
    packed |= uint256(uint160(address(_metadata.dataSource))) << 84;
  }

  /**
    @notice
    Expand the funding cycle metadata.

    @param _fundingCycle The funding cycle having its metadata expanded.

    @return metadata The metadata object.
  */
  function expandMetadata(SPFundingCycle memory _fundingCycle)
    internal
    pure
    returns (SPFundingCycleMetadata memory metadata)
  {
    return
      SPFundingCycleMetadata(
        global(_fundingCycle),
        reservedRate(_fundingCycle),
        redemptionRate(_fundingCycle),
        ballotRedemptionRate(_fundingCycle),
        payPaused(_fundingCycle),
        distributionsPaused(_fundingCycle),
        redeemPaused(_fundingCycle),
        burnPaused(_fundingCycle),
        mintingAllowed(_fundingCycle),
        changeTokenAllowed(_fundingCycle),
        terminalMigrationAllowed(_fundingCycle),
        controllerMigrationAllowed(_fundingCycle),
        shouldHoldFees(_fundingCycle),
        useTotalOverflowForRedemptions(_fundingCycle),
        useDataSourceForPay(_fundingCycle),
        useDataSourceForRedeem(_fundingCycle),
        dataSource(_fundingCycle)
      );
  }
}
