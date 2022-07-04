// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './helpers/TestBaseWorkflow.sol';
import '../SPReconfigurationBufferBallot.sol';
import '../SPETHERC20SplitsPayer.sol';

contract TestEIP165 is TestBaseWorkflow {
  bytes4 constant notSupportedInterface = 0xffffffff;

  uint256 constant projectId = 2;
  uint256 constant splitsProjectID = 3;
  address payable constant splitsBeneficiary = payable(address(420));
  uint256 constant splitsDomain = 1;
  uint256 constant splitsGroup = 1;
  bool constant splitsPreferClaimedTokens = false;
  string constant splitsMemo = '';
  bytes constant splitsMetadata = '';
  bool constant splitsPreferAddToBalance = true;
  address constant splitsOwner = address(420);

  function testSPController() public {
    SPController controller = SPController();

    // Should support these interfaces
    assertTrue(controller.supportsInterface(type(IERC165).interfaceId));
    assertTrue(controller.supportsInterface(type(ISPController).interfaceId));
    assertTrue(controller.supportsInterface(type(ISPMigratable).interfaceId));
    assertTrue(controller.supportsInterface(type(ISPOperatable).interfaceId));

    // Make sure it doesn't always return true
    assertTrue(!controller.supportsInterface(notSupportedInterface));
  }

  function testSPERC20PaymentTerminal() public {
    SPERC20PaymentTerminal terminal = new SPERC20PaymentTerminal(
      SPToken(),
      SPLibraries().USD(), // currency
      SPLibraries().ETH(), // base weight currency
      1, // SPSplitsGroupe
      SPOperatorStore(),
      SPProjects(),
      SPDirectory(),
      SPSplitsStore(),
      SPPrices(),
      SPPaymentTerminalStore(),
      multisig()
    );

    // Should support these interfaces
    assertTrue(terminal.supportsInterface(type(IERC165).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPPayoutRedemptionPaymentTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPPayoutTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPPaymentTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPAllowanceTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPRedemptionTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPSingleTokenPaymentTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPOperatable).interfaceId));

    // Make sure it doesn't always return true
    assertTrue(!terminal.supportsInterface(notSupportedInterface));
  }

  function testSPETHPaymentTerminal() public {
    SPETHPaymentTerminal terminal = SPETHPaymentTerminal();

    // Should support these interfaces
    assertTrue(terminal.supportsInterface(type(IERC165).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPPayoutRedemptionPaymentTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPPayoutTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPPaymentTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPAllowanceTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPRedemptionTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPSingleTokenPaymentTerminal).interfaceId));
    assertTrue(terminal.supportsInterface(type(ISPOperatable).interfaceId));

    // Make sure it doesn't always return true
    assertTrue(!terminal.supportsInterface(notSupportedInterface));
  }

  function testSPProjects() public {
    SPProjects projects = SPProjects();

    // Should support these interfaces
    assertTrue(projects.supportsInterface(type(IERC165).interfaceId));
    assertTrue(projects.supportsInterface(type(IERC721).interfaceId));
    assertTrue(projects.supportsInterface(type(IERC721Metadata).interfaceId));
    assertTrue(projects.supportsInterface(type(ISPProjects).interfaceId));
    assertTrue(projects.supportsInterface(type(ISPOperatable).interfaceId));

    // Make sure it doesn't always return true
    assertTrue(!projects.supportsInterface(notSupportedInterface));
  }

  function testSPReconfigurationBufferBallot() public {
    SPReconfigurationBufferBallot ballot = new SPReconfigurationBufferBallot(
      3000,
      SPFundingCycleStore()
    );

    // Should support these interfaces
    assertTrue(ballot.supportsInterface(type(IERC165).interfaceId));
    assertTrue(ballot.supportsInterface(type(ISPReconfigurationBufferBallot).interfaceId));
    assertTrue(ballot.supportsInterface(type(ISPFundingCycleBallot).interfaceId));

    // Make sure it doesn't always return true
    assertTrue(!ballot.supportsInterface(notSupportedInterface));
  }

  function testSPETHERC20SplitsPayer() public {
    SPETHERC20SplitsPayer splitsPayer = new SPETHERC20SplitsPayer(
      splitsProjectID,
      splitsDomain,
      splitsGroup,
      SPSplitsStore(),
      projectId,
      splitsBeneficiary,
      splitsPreferClaimedTokens,
      splitsMemo,
      splitsMetadata,
      splitsPreferAddToBalance,
      splitsOwner
    );

    // Should support these interfaces
    assertTrue(splitsPayer.supportsInterface(type(IERC165).interfaceId));
    assertTrue(splitsPayer.supportsInterface(type(ISPSplitsPayer).interfaceId));
    assertTrue(splitsPayer.supportsInterface(type(ISPProjectPayer).interfaceId));

    // Make sure it doesn't always return true
    assertTrue(!splitsPayer.supportsInterface(notSupportedInterface));
  }
}
