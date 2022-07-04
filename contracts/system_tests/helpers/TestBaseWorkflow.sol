// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './hevm.sol';
import '../../../lib/ds-test/src/test.sol';

import '../../SPController.sol';
import '../../SPDirectory.sol';
import '../../SPETHPaymentTerminal.sol';
import '../../SPERC20PaymentTerminal.sol';
import '../../SPSingleTokenPaymentTerminalStore.sol';
import '../../SPFundingCycleStore.sol';
import '../../SPOperatorStore.sol';
import '../../SPPrices.sol';
import '../../SPProjects.sol';
import '../../SPSplitsStore.sol';
import '../../SPToken.sol';
import '../../SPTokenStore.sol';

import '../../structs/SPDidPayData.sol';
import '../../structs/SPDidRedeemData.sol';
import '../../structs/SPFee.sol';
import '../../structs/SPFundAccessConstraints.sol';
import '../../structs/SPFundingCycle.sol';
import '../../structs/SPFundingCycleData.sol';
import '../../structs/SPFundingCycleMetadata.sol';
import '../../structs/SPGroupedSplits.sol';
import '../../structs/SPOperatorData.sol';
import '../../structs/SPPayParamsData.sol';
import '../../structs/SPProjectMetadata.sol';
import '../../structs/SPRedeemParamsData.sol';
import '../../structs/SPSplit.sol';

import '../../interfaces/ISPPaymentTerminal.sol';
import '../../interfaces/ISPToken.sol';

import './AccessSPLib.sol';

import '@paulrberg/contracts/math/PRBMath.sol';

// Base contract for Juicebox system tests.
//
// Provides common functionality, such as deploying contracts on test setup.
contract TestBaseWorkflow is DSTest {
  //*********************************************************************//
  // --------------------- private stored properties ------------------- //
  //*********************************************************************//

  // Multisig address used for testing.
  address private _multisig = address(123);

  address private _beneficiary = address(69420);

  // EVM Cheat codes - test addresses via prank and startPrank in hevm
  Hevm public evm = Hevm(HEVM_ADDRESS);

  // SPOperatorStore
  SPOperatorStore private _SPOperatorStore;
  // SPProjects
  SPProjects private _SPProjects;
  // SPPrices
  SPPrices private _SPPrices;
  // SPDirectory
  SPDirectory private _SPDirectory;
  // SPFundingCycleStore
  SPFundingCycleStore private _SPFundingCycleStore;
  // SPToken
  SPToken private _SPToken;
  // SPTokenStore
  SPTokenStore private _SPTokenStore;
  // SPSplitsStore
  SPSplitsStore private _SPSplitsStore;
  // SPController
  SPController private _SPController;
  // SPETHPaymentTerminalStore
  SPSingleTokenPaymentTerminalStore private _SPPaymentTerminalStore;
  // SPETHPaymentTerminal
  SPETHPaymentTerminal private _SPETHPaymentTerminal;
  // SPERC20PaymentTerminal
  SPERC20PaymentTerminal private _SPERC20PaymentTerminal;
  // AccessSPLib
  AccessSPLib private _accessSPLib;

  //*********************************************************************//
  // ------------------------- internal views -------------------------- //
  //*********************************************************************//

  function multisig() internal view returns (address) {
    return _multisig;
  }

  function beneficiary() internal view returns (address) {
    return _beneficiary;
  }

  function SPOperatorStore() internal view returns (SPOperatorStore) {
    return _SPOperatorStore;
  }

  function SPProjects() internal view returns (SPProjects) {
    return _SPProjects;
  }

  function SPPrices() internal view returns (SPPrices) {
    return _SPPrices;
  }

  function SPDirectory() internal view returns (SPDirectory) {
    return _SPDirectory;
  }

  function SPFundingCycleStore() internal view returns (SPFundingCycleStore) {
    return _SPFundingCycleStore;
  }

  function SPTokenStore() internal view returns (SPTokenStore) {
    return _SPTokenStore;
  }

  function SPSplitsStore() internal view returns (SPSplitsStore) {
    return _SPSplitsStore;
  }

  function SPController() internal view returns (SPController) {
    return _SPController;
  }

  function SPPaymentTerminalStore() internal view returns (SPSingleTokenPaymentTerminalStore) {
    return _SPPaymentTerminalStore;
  }

  function SPETHPaymentTerminal() internal view returns (SPETHPaymentTerminal) {
    return _SPETHPaymentTerminal;
  }

  function SPERC20PaymentTerminal() internal view returns (SPERC20PaymentTerminal) {
    return _SPERC20PaymentTerminal;
  }

  function SPToken() internal view returns (SPToken) {
    return _SPToken;
  }

  function SPLibraries() internal view returns (AccessSPLib) {
    return _accessSPLib;
  }

  //*********************************************************************//
  // --------------------------- test setup ---------------------------- //
  //*********************************************************************//

  // Deploys and initializes contracts for testing.
  function setUp() public virtual {
    // Labels
    evm.label(_multisig, 'projectOwner');
    evm.label(_beneficiary, 'beneficiary');

    // SPOperatorStore
    _SPOperatorStore = new SPOperatorStore();
    evm.label(address(_SPOperatorStore), 'SPOperatorStore');

    // SPProjects
    _SPProjects = new SPProjects(_SPOperatorStore);
    evm.label(address(_SPProjects), 'SPProjects');

    // SPPrices
    _SPPrices = new SPPrices(_multisig);
    evm.label(address(_SPPrices), 'SPPrices');

    address contractAtNoncePlusOne = addressFrom(address(this), 5);

    // SPFundingCycleStore
    _SPFundingCycleStore = new SPFundingCycleStore(ISPDirectory(contractAtNoncePlusOne));
    evm.label(address(_SPFundingCycleStore), 'SPFundingCycleStore');

    // SPDirectory
    _SPDirectory = new SPDirectory(_SPOperatorStore, _SPProjects, _SPFundingCycleStore, _multisig);
    evm.label(address(_SPDirectory), 'SPDirectory');

    // SPTokenStore
    _SPTokenStore = new SPTokenStore(_SPOperatorStore, _SPProjects, _SPDirectory);
    evm.label(address(_SPTokenStore), 'SPTokenStore');

    // SPSplitsStore
    _SPSplitsStore = new SPSplitsStore(_SPOperatorStore, _SPProjects, _SPDirectory);
    evm.label(address(_SPSplitsStore), 'SPSplitsStore');

    // SPController
    _SPController = new SPController(
      _SPOperatorStore,
      _SPProjects,
      _SPDirectory,
      _SPFundingCycleStore,
      _SPTokenStore,
      _SPSplitsStore
    );
    evm.label(address(_SPController), 'SPController');

    evm.prank(_multisig);
    _SPDirectory.setIsAllowedToSetFirstController(address(_SPController), true);

    // SPETHPaymentTerminalStore
    _SPPaymentTerminalStore = new SPSingleTokenPaymentTerminalStore(
      _SPDirectory,
      _SPFundingCycleStore,
      _SPPrices
    );
    evm.label(address(_SPPaymentTerminalStore), 'SPSingleTokenPaymentTerminalStore');

    // AccessSPLib
    _accessSPLib = new AccessSPLib();

    // SPETHPaymentTerminal
    _SPETHPaymentTerminal = new SPETHPaymentTerminal(
      _accessSPLib.ETH(),
      _SPOperatorStore,
      _SPProjects,
      _SPDirectory,
      _SPSplitsStore,
      _SPPrices,
      _SPPaymentTerminalStore,
      _multisig
    );
    evm.label(address(_SPETHPaymentTerminal), 'SPETHPaymentTerminal');

    evm.prank(_multisig);
    _SPToken = new SPToken('MyToken', 'MT');

    evm.prank(_multisig);
    _SPToken.mint(0, _multisig, 100 * 10**18);

    // SPERC20PaymentTerminal
    _SPERC20PaymentTerminal = new SPERC20PaymentTerminal(
      _SPToken,
      _accessSPLib.ETH(), // currency
      _accessSPLib.ETH(), // base weight currency
      1, // SPSplitsGroupe
      _SPOperatorStore,
      _SPProjects,
      _SPDirectory,
      _SPSplitsStore,
      _SPPrices,
      _SPPaymentTerminalStore,
      _multisig
    );
    evm.label(address(_SPERC20PaymentTerminal), 'SPERC20PaymentTerminal');
  }

  //https://ethereum.stackexchange.com/questions/24248/how-to-calculate-an-ethereum-contracts-address-during-its-creation-using-the-so
  function addressFrom(address _origin, uint256 _nonce) internal pure returns (address _address) {
    bytes memory data;
    if (_nonce == 0x00) data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80));
    else if (_nonce <= 0x7f)
      data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, uint8(_nonce));
    else if (_nonce <= 0xff)
      data = abi.encodePacked(bytes1(0xd7), bytes1(0x94), _origin, bytes1(0x81), uint8(_nonce));
    else if (_nonce <= 0xffff)
      data = abi.encodePacked(bytes1(0xd8), bytes1(0x94), _origin, bytes1(0x82), uint16(_nonce));
    else if (_nonce <= 0xffffff)
      data = abi.encodePacked(bytes1(0xd9), bytes1(0x94), _origin, bytes1(0x83), uint24(_nonce));
    else data = abi.encodePacked(bytes1(0xda), bytes1(0x94), _origin, bytes1(0x84), uint32(_nonce));
    bytes32 hash = keccak256(data);
    assembly {
      mstore(0, hash)
      _address := mload(0)
    }
  }
}
