// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './helpers/TestBaseWorkflow.sol';

contract TestLaunchProject is TestBaseWorkflow {
  SPController controller;
  SPProjectMetadata _projectMetadata;
  SPFundingCycleData _data;
  SPFundingCycleMetadata _metadata;
  SPGroupedSplits[] _groupedSplits; // Default empty
  SPFundAccessConstraints[] _fundAccessConstraints; // Default empty
  ISPPaymentTerminal[] _terminals; // Default empty

  function setUp() public override {
    super.setUp();

    controller = SPController();

    _projectMetadata = SPProjectMetadata({content: 'myIPFSHash', domain: 1});

    _data = SPFundingCycleData({
      duration: 14,
      weight: 1000 * 10**18,
      discountRate: 450000000,
      ballot: ISPFundingCycleBallot(address(0))
    });

    _metadata = SPFundingCycleMetadata({
      global: SPGlobalFundingCycleMetadata({allowSetTerminals: false, allowSetController: false}),
      reservedRate: 5000, //50%
      redemptionRate: 5000, //50%
      ballotRedemptionRate: 0,
      pausePay: false,
      pauseDistributions: false,
      pauseRedeem: false,
      pauseBurn: false,
      allowMinting: false,
      allowChangeToken: false,
      allowTerminalMigration: false,
      allowControllerMigration: false,
      holdFees: false,
      useTotalOverflowForRedemptions: false,
      useDataSourceForPay: false,
      useDataSourceForRedeem: false,
      dataSource: address(0)
    });
  }

  function testLaunchProject() public {
    uint256 projectId = controller.launchProjectFor(
      msg.sender,
      _projectMetadata,
      _data,
      _metadata,
      block.timestamp,
      _groupedSplits,
      _fundAccessConstraints,
      _terminals,
      ''
    );

    SPFundingCycle memory fundingCycle = SPFundingCycleStore().currentOf(projectId); //, latestConfig);

    assertEq(fundingCycle.number, 1);
    assertEq(fundingCycle.weight, 1000 * 10**18);
  }

  function testLaunchProjectFuzzWeight(uint256 WEIGHT) public {
    _data = SPFundingCycleData({
      duration: 14,
      weight: WEIGHT,
      discountRate: 450000000,
      ballot: ISPFundingCycleBallot(address(0))
    });

    uint256 projectId;

    // expectRevert on the next call if weight overflowing
    if (WEIGHT > type(uint88).max) {
      evm.expectRevert(abi.encodeWithSignature('INVALID_WEIGHT()'));

      projectId = controller.launchProjectFor(
        msg.sender,
        _projectMetadata,
        _data,
        _metadata,
        block.timestamp,
        _groupedSplits,
        _fundAccessConstraints,
        _terminals,
        ''
      );
    } else {
      projectId = controller.launchProjectFor(
        msg.sender,
        _projectMetadata,
        _data,
        _metadata,
        block.timestamp,
        _groupedSplits,
        _fundAccessConstraints,
        _terminals,
        ''
      );

      SPFundingCycle memory fundingCycle = SPFundingCycleStore().currentOf(projectId); //, latestConfig);

      assertEq(fundingCycle.number, 1);
      assertEq(fundingCycle.weight, WEIGHT);
    }
  }
}
