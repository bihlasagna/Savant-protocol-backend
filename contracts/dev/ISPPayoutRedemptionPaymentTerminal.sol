// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './../structs/SPFee.sol';
import './ISPAllowanceTerminal.sol';
import './ISPDirectory.sol';
import './ISPFeeGauge.sol';
import './ISPPayDelegate.sol';
import './ISPPaymentTerminal.sol';
import './ISPPayoutTerminal.sol';
import './ISPPrices.sol';
import './ISPProjects.sol';
import './ISPRedemptionDelegate.sol';
import './ISPRedemptionTerminal.sol';
import './ISPSingleTokenPaymentTerminal.sol';
import './ISPSingleTokenPaymentTerminalStore.sol';
import './ISPSplitsStore.sol';

interface ISPPayoutRedemptionPaymentTerminal is
  ISPPaymentTerminal,
  ISPPayoutTerminal,
  ISPAllowanceTerminal,
  ISPRedemptionTerminal
{
  event AddToBalance(
    uint256 indexed projectId,
    uint256 amount,
    uint256 refundedFees,
    string memo,
    bytes metadata,
    address caller
  );

  event Migrate(
    uint256 indexed projectId,
    ISPPaymentTerminal indexed to,
    uint256 amount,
    address caller
  );

  event DistributePayouts(
    uint256 indexed fundingCycleConfiguration,
    uint256 indexed fundingCycleNumber,
    uint256 indexed projectId,
    address beneficiary,
    uint256 amount,
    uint256 distributedAmount,
    uint256 fee,
    uint256 beneficiaryDistributionAmount,
    string memo,
    address caller
  );

  event UseAllowance(
    uint256 indexed fundingCycleConfiguration,
    uint256 indexed fundingCycleNumber,
    uint256 indexed projectId,
    address beneficiary,
    uint256 amount,
    uint256 distributedAmount,
    uint256 netDistributedamount,
    string memo,
    address caller
  );

  event HoldFee(
    uint256 indexed projectId,
    uint256 indexed amount,
    uint256 indexed fee,
    uint256 feeDiscount,
    address beneficiary,
    address caller
  );

  event ProcessFee(
    uint256 indexed projectId,
    uint256 indexed amount,
    bool indexed wasHeld,
    address beneficiary,
    address caller
  );

  event RefundHeldFees(
    uint256 indexed projectId,
    uint256 indexed amount,
    uint256 indexed refundedFees,
    uint256 leftoverAmount,
    address caller
  );

  event Pay(
    uint256 indexed fundingCycleConfiguration,
    uint256 indexed fundingCycleNumber,
    uint256 indexed projectId,
    address payer,
    address beneficiary,
    uint256 amount,
    uint256 beneficiaryTokenCount,
    string memo,
    bytes metadata,
    address caller
  );

  event DelegateDidPay(ISPPayDelegate indexed delegate, SPDidPayData data, address caller);

  event RedeemTokens(
    uint256 indexed fundingCycleConfiguration,
    uint256 indexed fundingCycleNumber,
    uint256 indexed projectId,
    address holder,
    address beneficiary,
    uint256 tokenCount,
    uint256 reclaimedAmount,
    string memo,
    bytes metadata,
    address caller
  );

  event DelegateDidRedeem(
    ISPRedemptionDelegate indexed delegate,
    SPDidRedeemData data,
    address caller
  );

  event DistributeToPayoutSplit(
    uint256 indexed projectId,
    uint256 indexed domain,
    uint256 indexed group,
    SPSplit split,
    uint256 amount,
    address caller
  );

  event SetFee(uint256 fee, address caller);

  event SetFeeGauge(ISPFeeGauge indexed feeGauge, address caller);

  event SetFeelessAddress(address indexed addrs, bool indexed flag, address caller);

  function projects() external view returns (ISPProjects);

  function splitsStore() external view returns (ISPSplitsStore);

  function directory() external view returns (ISPDirectory);

  function prices() external view returns (ISPPrices);

  function store() external view returns (ISPSingleTokenPaymentTerminalStore);

  function baseWeightCurrency() external view returns (uint256);

  function payoutSplitsGroup() external view returns (uint256);

  function heldFeesOf(uint256 _projectId) external view returns (SPFee[] memory);

  function fee() external view returns (uint256);

  function feeGauge() external view returns (ISPFeeGauge);

  function isFeelessAddress(address _contract) external view returns (bool);

  function migrate(uint256 _projectId, ISPPaymentTerminal _to) external returns (uint256 balance);

  function processFees(uint256 _projectId) external;

  function setFee(uint256 _fee) external;

  function setFeeGauge(ISPFeeGauge _feeGauge) external;

  function setFeelessAddress(address _contract, bool _flag) external;
}
