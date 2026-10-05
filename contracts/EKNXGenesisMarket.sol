// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IEurekaNexusMarketToken is IERC20 {
    function enableTransfers() external;
}

interface IPancakeRouterV2 {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

/// @title Eureka Nexus Genesis Market
/// @notice Starts with 1M EKNX and 0 BNB. Buyers provide all launch BNB.
///
/// 650k EKNX: bonding curve.
/// 350k EKNX: graduation liquidity.
///
/// At 25 BNB net curve reserve:
/// 21 BNB + 350k EKNX -> PancakeSwap V2.
/// 3 BNB -> Operations.
/// 1 BNB -> Founder revenue.
/// LP -> dead address.
///
/// A curve holder may sell back only the net quantity that address actually
/// bought from this curve. Mining balances cannot be used to drain curve BNB.
contract EKNXGenesisMarket is ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant SALE_ALLOCATION = 650_000 ether;
    uint256 public constant LIQUIDITY_ALLOCATION = 350_000 ether;
    uint256 public constant GENESIS_MARKET_ALLOCATION = 1_000_000 ether;

    uint256 public constant GRADUATION_TARGET_BNB = 25 ether;
    uint256 public constant LIQUIDITY_BNB = 21 ether;
    uint256 public constant OPERATIONS_BNB = 3 ether;
    uint256 public constant FOUNDER_BNB = 1 ether;

    uint256 public constant MIN_TRADE = 1 ether;

    // R(x) = 11 BNB*x/650k + 14 BNB*(x/650k)^2
    // R(650k) = 25 BNB.
    // Final marginal price = 0.000060 BNB/EKNX.
    // LP graduation price = 21/350000 = 0.000060 BNB/EKNX.
    uint256 private constant LINEAR_RESERVE_AT_CAP = 11 ether;
    uint256 private constant QUADRATIC_RESERVE_AT_CAP = 14 ether;

    address public constant DEAD =
        0x000000000000000000000000000000000000dEaD;

    IEurekaNexusMarketToken public immutable token;
    address public immutable pancakeRouter;
    address payable public immutable operationsWallet;
    address payable public immutable founderRevenueWallet;

    address public launcher;
    bool public launched;
    bool public graduated;

    uint256 public sold;
    uint256 public accountedReserveBNB;

    mapping(address => uint256) public curvePosition;

    event MarketLaunched(uint256 timestamp);
    event Bought(
        address indexed buyer,
        uint256 tokenAmount,
        uint256 bnbCost,
        uint256 netSold
    );
    event SoldBack(
        address indexed seller,
        uint256 tokenAmount,
        uint256 bnbRefund,
        uint256 netSold
    );
    event Graduated(
        uint256 liquidityBNB,
        uint256 liquidityEKNX,
        uint256 operationsBNB,
        uint256 founderBNB,
        address indexed lpRecipient
    );
    event ForcedBNBSweptToOperations(uint256 amount);

    error NotLauncher();
    error AlreadyLaunched();
    error NotLaunched();
    error AlreadyGraduated();
    error InvalidAddress();
    error InvalidAmount();
    error SaleCapExceeded();
    error InsufficientBNB();
    error InsufficientCurvePosition();
    error Slippage();
    error TransferFailed();
    error ReserveInvariant();
    error LiquidityRatioChanged();
    error DirectBNBNotAccepted();

    constructor(
        address token_,
        address pancakeRouter_,
        address payable operationsWallet_,
        address payable founderRevenueWallet_,
        address launcher_
    ) {
        require(block.chainid == 56, "BSC_MAINNET_ONLY");

        if (
            token_ == address(0) ||
            pancakeRouter_ == address(0) ||
            operationsWallet_ == address(0) ||
            founderRevenueWallet_ == address(0) ||
            launcher_ == address(0)
        ) revert InvalidAddress();

        token = IEurekaNexusMarketToken(token_);
        pancakeRouter = pancakeRouter_;
        operationsWallet = operationsWallet_;
        founderRevenueWallet = founderRevenueWallet_;
        launcher = launcher_;
    }

    modifier liveCurve() {
        if (!launched) revert NotLaunched();
        if (graduated) revert AlreadyGraduated();
        _;
    }

    function launch() external {
        if (msg.sender != launcher) revert NotLauncher();
        if (launched) revert AlreadyLaunched();

        if (
            token.balanceOf(address(this)) !=
            GENESIS_MARKET_ALLOCATION
        ) revert ReserveInvariant();

        launched = true;
        launcher = address(0);

        emit MarketLaunched(block.timestamp);
    }

    function reserveAt(
        uint256 soldAmount
    ) public pure returns (uint256) {
        if (soldAmount > SALE_ALLOCATION) {
            revert SaleCapExceeded();
        }

        uint256 linear =
            (LINEAR_RESERVE_AT_CAP * soldAmount) /
            SALE_ALLOCATION;

        uint256 quadratic =
            (QUADRATIC_RESERVE_AT_CAP *
                soldAmount *
                soldAmount) /
            SALE_ALLOCATION /
            SALE_ALLOCATION;

        return linear + quadratic;
    }

    function quoteBuy(
        uint256 tokenAmount
    ) public view returns (uint256) {
        if (tokenAmount < MIN_TRADE) {
            revert InvalidAmount();
        }

        uint256 afterSold = sold + tokenAmount;

        if (afterSold > SALE_ALLOCATION) {
            revert SaleCapExceeded();
        }

        return reserveAt(afterSold) - reserveAt(sold);
    }

    function quoteSell(
        uint256 tokenAmount
    ) public view returns (uint256) {
        if (
            tokenAmount < MIN_TRADE ||
            tokenAmount > sold
        ) revert InvalidAmount();

        return
            reserveAt(sold) -
            reserveAt(sold - tokenAmount);
    }

    function buyExactTokens(
        uint256 tokenAmount
    )
        external
        payable
        nonReentrant
        liveCurve
    {
        uint256 cost = quoteBuy(tokenAmount);

        if (msg.value < cost) {
            revert InsufficientBNB();
        }

        sold += tokenAmount;
        accountedReserveBNB += cost;
        curvePosition[msg.sender] += tokenAmount;

        IERC20(address(token)).safeTransfer(
            msg.sender,
            tokenAmount
        );

        uint256 refund = msg.value - cost;

        if (refund != 0) {
            (bool refunded, ) =
                payable(msg.sender).call{
                    value: refund
                }("");

            if (!refunded) revert TransferFailed();
        }

        emit Bought(
            msg.sender,
            tokenAmount,
            cost,
            sold
        );

        if (sold == SALE_ALLOCATION) {
            _graduate();
        }
    }

    function sellExactTokens(
        uint256 tokenAmount,
        uint256 minBnbOut
    )
        external
        nonReentrant
        liveCurve
    {
        if (
            curvePosition[msg.sender] <
            tokenAmount
        ) revert InsufficientCurvePosition();

        uint256 refund = quoteSell(tokenAmount);

        if (refund < minBnbOut) {
            revert Slippage();
        }

        if (refund > accountedReserveBNB) {
            revert ReserveInvariant();
        }

        curvePosition[msg.sender] -= tokenAmount;
        sold -= tokenAmount;
        accountedReserveBNB -= refund;

        IERC20(address(token)).safeTransferFrom(
            msg.sender,
            address(this),
            tokenAmount
        );

        (bool paid, ) =
            payable(msg.sender).call{
                value: refund
            }("");

        if (!paid) revert TransferFailed();

        emit SoldBack(
            msg.sender,
            tokenAmount,
            refund,
            sold
        );
    }

    function _graduate() internal {
        if (sold != SALE_ALLOCATION) {
            revert ReserveInvariant();
        }

        if (
            accountedReserveBNB !=
            GRADUATION_TARGET_BNB
        ) revert ReserveInvariant();

        if (
            address(this).balance <
            GRADUATION_TARGET_BNB
        ) revert ReserveInvariant();

        if (
            token.balanceOf(address(this)) !=
            LIQUIDITY_ALLOCATION
        ) revert ReserveInvariant();

        graduated = true;

        token.enableTransfers();

        IERC20(address(token)).forceApprove(
            pancakeRouter,
            LIQUIDITY_ALLOCATION
        );

        (
            uint256 amountToken,
            uint256 amountBNB,
        ) = IPancakeRouterV2(
            pancakeRouter
        ).addLiquidityETH{
            value: LIQUIDITY_BNB
        }(
            address(token),
            LIQUIDITY_ALLOCATION,
            LIQUIDITY_ALLOCATION,
            LIQUIDITY_BNB,
            DEAD,
            block.timestamp
        );

        if (
            amountToken != LIQUIDITY_ALLOCATION ||
            amountBNB != LIQUIDITY_BNB
        ) revert LiquidityRatioChanged();

        accountedReserveBNB -= LIQUIDITY_BNB;

        (bool opsPaid, ) =
            operationsWallet.call{
                value: OPERATIONS_BNB
            }("");

        if (!opsPaid) revert TransferFailed();

        accountedReserveBNB -=
            OPERATIONS_BNB;

        (bool founderPaid, ) =
            founderRevenueWallet.call{
                value: FOUNDER_BNB
            }("");

        if (!founderPaid) {
            revert TransferFailed();
        }

        accountedReserveBNB -= FOUNDER_BNB;

        if (accountedReserveBNB != 0) {
            revert ReserveInvariant();
        }

        uint256 forcedExcess =
            address(this).balance;

        if (forcedExcess != 0) {
            (bool swept, ) =
                operationsWallet.call{
                    value: forcedExcess
                }("");

            if (!swept) {
                revert TransferFailed();
            }

            emit ForcedBNBSweptToOperations(
                forcedExcess
            );
        }

        emit Graduated(
            LIQUIDITY_BNB,
            LIQUIDITY_ALLOCATION,
            OPERATIONS_BNB,
            FOUNDER_BNB,
            DEAD
        );
    }

    receive() external payable {
        if (msg.sender != pancakeRouter) {
            revert DirectBNBNotAccepted();
        }
    }
}
