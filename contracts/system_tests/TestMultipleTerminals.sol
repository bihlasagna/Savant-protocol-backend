// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@paulrberg/contracts/math/PRBMath.sol';
import './helpers/TestBaseWorkflow.sol';
import './mock/MockPriceFeed.sol';
import '@paulrberg/contracts/math/PRBMath.sol';

contract TestMultipleTerminals is TestBaseWorkflow {
  SPController controller;
  SPProjectMetadata _projectMetadata;
  SPFundingCycleData _data;
  SPFundingCycleMetadata _metadata;
  SPGroupedSplits[] _groupedSplits;
  SPFundAccessConstraints[] _fundAccessConstraints;

  ISPPaymentTerminal[] _terminals;
  SPERC20PaymentTerminal ERC20terminal;
  SPETHPaymentTerminal ETHterminal;

  SPTokenStore _tokenStore;
  address _projectOwner;

  address caller = address(6942069);

  uint256 FAKE_PRICE = 10;
  uint256 WEIGHT = 1000 * 10**18;
  uint256 projectId;

  function setUp() public override {
    super.setUp();
    evm.label(caller, 'caller');

    _groupedSplits.push();
    _groupedSplits[0].group = 1;
    _groupedSplits[0].splits.push(
      SPSplit({
        preferClaimed: false,
        preferAddToBalance: false,
        percent: SPLibraries().SPLITS_TOTAL_PERCENT(),
        projectId: 0,
        beneficiary: payable(caller),
        lockedUntil: 0,
        allocator: ISPSplitAllocator(address(0))
      })
    );

    _projectOwner = multisig();

    _tokenStore = SPTokenStore();

    controller = SPController();

    _projectMetadata = SPProjectMetadata({content: 'myIPFSHash', domain: 1});

    _data = SPFundingCycleData({
      duration: 14,
      weight: WEIGHT,
      discountRate: 450_000_000, // out of 1_000_000_000
      ballot: ISPFundingCycleBallot(address(0))
    });

    _metadata = SPFundingCycleMetadata({
      global: SPGlobalFundingCycleMetadata({allowSetTerminals: false, allowSetController: false}),
      reservedRate: 5000, //50%
      redemptionRate: 10000, //100%
      ballotRedemptionRate: 0,
      pausePay: false,
      pauseDistributions: false,
      pauseRedeem: false,
      pauseBurn: false,
      allowMinting: true,
      allowChangeToken: false,
      allowTerminalMigration: false,
      allowControllerMigration: false,
      holdFees: false,
      useTotalOverflowForRedemptions: true,
      useDataSourceForPay: false,
      useDataSourceForRedeem: false,
      dataSource: address(0)
    });

    ERC20terminal = new SPERC20PaymentTerminal(
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
    evm.label(address(ERC20terminal), 'SPERC20PaymentTerminalUSD');

    ETHterminal = SPETHPaymentTerminal();

    _fundAccessConstraints.push(
      SPFundAccessConstraints({
        terminal: ERC20terminal,
        token: address(SPToken()),
        distributionLimit: 10 * 10**18,
        overflowAllowance: 5 * 10**18,
        distributionLimitCurrency: SPLibraries().USD(),
        overflowAllowanceCurrency: SPLibraries().USD()
      })
    );

    _fundAccessConstraints.push(
      SPFundAccessConstraints({
        terminal: ETHterminal,
        token: SPLibraries().ETHToken(),
        distributionLimit: 10 * 10**18,
        overflowAllowance: 5 * 10**18,
        distributionLimitCurrency: SPLibraries().ETH(),
        overflowAllowanceCurrency: SPLibraries().ETH()
      })
    );

    _terminals.push(ERC20terminal);
    _terminals.push(ETHterminal);

    projectId = controller.launchProjectFor(
      _projectOwner,
      _projectMetadata,
      _data,
      _metadata,
      block.timestamp,
      _groupedSplits,
      _fundAccessConstraints,
      _terminals,
      ''
    );

    evm.startPrank(_projectOwner);
    MockPriceFeed _priceFeed = new MockPriceFeed(FAKE_PRICE);
    MockPriceFeed _priceFeedUsdEth = new MockPriceFeed(FAKE_PRICE);
    evm.label(address(_priceFeed), 'MockPrice Feed');

    SPPrices().addFeedFor(
      SPLibraries().USD(), // currency
      SPLibraries().ETH(), // base weight currency
      _priceFeedUsdEth
    );

    SPPrices().addFeedFor(
      SPLibraries().ETH(), // currency
      SPLibraries().USD(), // base weight currency
      _priceFeed
    );

    evm.stopPrank();
  }

  function testMultipleTerminal() public {
    // Send some token to the caller, so he can play
    evm.prank(_projectOwner);
    SPToken().transfer(caller, 20 * 10**18);

    // ---- Pay in token ----
    evm.prank(caller); // back to regular msg.sender (bug?)
    SPToken().approve(address(ERC20terminal), 20 * 10**18);
    evm.prank(caller); // back to regular msg.sender (bug?)
    ERC20terminal.pay(
      projectId,
      20 * 10**18,
      address(0),
      caller,
      0,
      false,
      'Forge test',
      new bytes(0)
    );

    // verify: beneficiary should have a balance of SPTokens (divided by 2 -> reserved rate = 50%)
    // price feed will return FAKE_PRICE*18 (for curr usd/base eth); since it's an 18 decimal terminal (ie calling getPrice(18) )
    uint256 _userTokenBalance = PRBMath.mulDiv(20 * 10**18, WEIGHT, 36 * FAKE_PRICE);
    assertEq(_tokenStore.balanceOf(caller, projectId), _userTokenBalance);

    // verify: balance in terminal should be up to date
    assertEq(SPPaymentTerminalStore().balanceOf(ERC20terminal, projectId), 20 * 10**18);

    // ---- Pay in ETH ----
    address beneficiaryTwo = address(696969);
    ETHterminal.pay{value: 20 ether}(
      projectId,
      20 ether,
      address(0),
      beneficiaryTwo,
      0,
      false,
      'Forge test',
      new bytes(0)
    ); // funding target met and 10 ETH are now in the overflow

    // verify: beneficiary should have a balance of SPTokens (divided by 2 -> reserved rate = 50%)
    uint256 _userEthBalance = PRBMath.mulDiv(20 ether, (WEIGHT / 10**18), 2);
    assertEq(_tokenStore.balanceOf(beneficiaryTwo, projectId), _userEthBalance);

    // verify: ETH balance in terminal should be up to date
    assertEq(SPPaymentTerminalStore().balanceOf(ETHterminal, projectId), 20 ether);

    // ---- Use allowance ----
    evm.startPrank(_projectOwner);
    ERC20terminal.useAllowanceOf(
      projectId,
      5 * 10**18, // amt in ETH (overflow allowance currency is in ETH)
      SPLibraries().USD(), // Currency -> (fake price is 10)
      address(0), //token (unused)
      1, // Min wei out
      payable(msg.sender), // Beneficiary
      'MEMO'
    );
    evm.stopPrank();

    // Funds leaving the contract -> take the fee
    assertEq(
      SPToken().balanceOf(msg.sender),
      PRBMath.mulDiv(
        5 * 10**18,
        SPLibraries().MAX_FEE(),
        SPLibraries().MAX_FEE() + ERC20terminal.fee()
      )
    );

    // Distribute the funding target ETH
    uint256 initBalance = caller.balance;
    evm.prank(_projectOwner);
    ETHterminal.distributePayoutsOf(
      projectId,
      10 * 10**18,
      SPLibraries().ETH(), // Currency
      address(0), //token (unused)
      0, // Min wei out
      'Foundry payment' // Memo
    );
    // Funds leaving the ecosystem -> fee taken
    assertEq(
      caller.balance,
      initBalance +
        PRBMath.mulDiv(
          10 * 10**18,
          SPLibraries().MAX_FEE(),
          ETHterminal.fee() + SPLibraries().MAX_FEE()
        )
    );

    // redeem eth from the overflow by the token holder:
    uint256 totalSupply = SPController().totalOutstandingTokensOf(projectId, 5000);
    uint256 overflow = SPPaymentTerminalStore().currentTotalOverflowOf(projectId, 18, 1);

    uint256 callerEthBalanceBefore = caller.balance;

    evm.prank(caller);
    ETHterminal.redeemTokensOf(
      caller,
      projectId,
      100_000,
      address(0), //token (unused)
      0,
      payable(caller),
      'gimme my money back',
      new bytes(0)
    );

    assertEq(caller.balance, callerEthBalanceBefore + ((100_000 * overflow) / totalSupply));
  }
}
