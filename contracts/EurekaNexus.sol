// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EKNXGenesisMarket} from "./EKNXGenesisMarket.sol";

/// @title Eureka Nexus (EKNX) — Mainnet Candidate v1.3
/// @notice BSC token with Genesis Market + work-proportional mining settlements.
///
/// GENESIS
/// - Maximum token supply: 100,000,000 EKNX.
/// - 1,000,000 EKNX are created at deployment.
/// - All genesis EKNX go directly to the Genesis Market contract.
/// - Founder/team/deployer receive 0 genesis EKNX.
///
/// PUBLIC MINING ECONOMICS
/// - Off-chain accounting epoch: 1 minute.
/// - GPU lane Era-0 ceiling: 5 EKNX/minute.
/// - CPU lane Era-0 ceiling: 0.8 EKNX/minute.
/// - Both ceilings halve every 4 years.
/// - Unused capacity is not carried into later days.
/// - The Pool calculates reward from difficulty-weighted valid work.
/// - More miners increase competition; they do not increase the on-chain ceiling.
///
/// SCALABLE PAYOUTS
/// - The Pool computes minute epochs off-chain.
/// - Completed epochs are aggregated into one cumulative Merkle settlement per day.
/// - 2 of 3 immutable operators must sign each daily settlement.
/// - A miner may claim from any published cumulative root.
/// - Claim mints only the difference not previously claimed.
/// - There is no fixed 50-EKNX minimum in the token contract.
///
/// IMPORTANT TRUST BOUNDARY
/// BSC cannot independently verify KAWPOW/RandomX pool shares.
/// Operator signatures attest to the Pool's work accounting, while this contract
/// enforces day ordering, era ceilings, hard supply caps, replay protection and claims.
contract EurekaNexus is ERC20, EIP712 {
    using ECDSA for bytes32;

    uint256 public constant MAX_SUPPLY = 100_000_000 ether;
    uint256 public constant GENESIS_MARKET_SUPPLY = 1_000_000 ether;
    uint256 public constant WORK_SUPPLY_CAP = 99_000_000 ether;

    uint256 public constant OPERATOR_THRESHOLD = 2;

    uint256 public constant MINING_DAY = 1 days;
    uint256 public constant HALVING_DAYS = 4 * 365;

    uint256 public constant GPU_ERA0_EPOCH_CAP = 5 ether;
    uint256 public constant CPU_ERA0_EPOCH_CAP = 8e17; // 0.8 EKNX
    uint256 public constant EPOCHS_PER_DAY = 1_440;

    bytes32 public constant SETTLEMENT_TYPEHASH =
        keccak256(
            "MiningSettlement(uint256 dayIndex,bytes32 merkleRoot,uint256 gpuDayReward,uint256 cpuDayReward,uint256 cumulativeGpu,uint256 cumulativeCpu)"
        );

    struct Settlement {
        bytes32 merkleRoot;
        uint256 gpuDayReward;
        uint256 cpuDayReward;
        uint256 cumulativeGpu;
        uint256 cumulativeCpu;
    }

    address public immutable marketContract;

    address[3] public operators;
    mapping(address => bool) public isOperator;

    address public miningActivator;
    uint256 public miningStart;

    uint256 public settledDays;
    uint256 public cumulativeGpuSettled;
    uint256 public cumulativeCpuSettled;

    mapping(uint256 => Settlement) public settlements;
    mapping(address => uint256) public claimedEntitlement;

    uint256 public workMinted;
    bool public transfersEnabled;

    event GenesisMarketCreated(
        address indexed marketContract,
        uint256 genesisSupply
    );
    event MiningActivated(uint256 indexed timestamp);
    event MiningSettlementPublished(
        uint256 indexed dayIndex,
        bytes32 indexed merkleRoot,
        uint256 gpuDayReward,
        uint256 cpuDayReward,
        uint256 cumulativeGpu,
        uint256 cumulativeCpu,
        uint256 era
    );
    event MiningClaimed(
        address indexed miner,
        uint256 indexed settlementDay,
        uint256 amount,
        uint256 cumulativeEntitlement
    );
    event TransfersEnabled(address indexed marketContract);

    error InvalidAddress();
    error InvalidOperatorSet();
    error OnlyMiningActivator();
    error MiningAlreadyActivated();
    error MiningNotActivated();
    error InvalidSettlementDay();
    error SettlementDayNotCompleted();
    error InvalidMerkleRoot();
    error WrongCumulativeTotals();
    error GpuRewardCapExceeded();
    error CpuRewardCapExceeded();
    error InsufficientOperatorApprovals();
    error DuplicateOperatorSignature();
    error InvalidMerkleProof();
    error NothingToClaim();
    error WorkSupplyCapExceeded();
    error MaxSupplyExceeded();
    error OnlyMarketContract();
    error TransfersLocked();

    constructor(
        address pancakeRouter,
        address payable operationsWallet,
        address payable founderRevenueWallet,
        address launcher,
        address operator1,
        address operator2,
        address operator3
    )
        ERC20("Eureka Nexus", "EKNX")
        EIP712("Eureka Nexus Mining Settlement", "1")
    {
        require(block.chainid == 56, "BSC_MAINNET_ONLY");

        if (
            pancakeRouter == address(0) ||
            operationsWallet == address(0) ||
            founderRevenueWallet == address(0) ||
            launcher == address(0)
        ) revert InvalidAddress();

        if (
            operator1 == address(0) ||
            operator2 == address(0) ||
            operator3 == address(0) ||
            operator1 == operator2 ||
            operator1 == operator3 ||
            operator2 == operator3
        ) revert InvalidOperatorSet();

        operators = [operator1, operator2, operator3];
        isOperator[operator1] = true;
        isOperator[operator2] = true;
        isOperator[operator3] = true;

        miningActivator = launcher;

        EKNXGenesisMarket market = new EKNXGenesisMarket(
            address(this),
            pancakeRouter,
            operationsWallet,
            founderRevenueWallet,
            launcher
        );

        marketContract = address(market);

        _mint(marketContract, GENESIS_MARKET_SUPPLY);

        emit GenesisMarketCreated(
            marketContract,
            GENESIS_MARKET_SUPPLY
        );
    }

    /// @notice Starts the mining clock exactly once.
    /// Call only when Pool + operators + public Miner are ready.
    function activateMining() external {
        if (msg.sender != miningActivator) revert OnlyMiningActivator();
        if (miningStart != 0) revert MiningAlreadyActivated();

        miningStart = block.timestamp;
        miningActivator = address(0);

        emit MiningActivated(block.timestamp);
    }

    function currentMiningDay() public view returns (uint256) {
        if (miningStart == 0) return 0;
        return (block.timestamp - miningStart) / MINING_DAY;
    }

    function eraForDay(uint256 dayIndex) public pure returns (uint256) {
        return dayIndex / HALVING_DAYS;
    }

    function currentHalvingEra() public view returns (uint256) {
        if (miningStart == 0) return 0;
        return eraForDay(currentMiningDay());
    }

    function gpuEpochCapForEra(uint256 era) public pure returns (uint256) {
        if (era >= 256) return 0;
        return GPU_ERA0_EPOCH_CAP >> era;
    }

    function cpuEpochCapForEra(uint256 era) public pure returns (uint256) {
        if (era >= 256) return 0;
        return CPU_ERA0_EPOCH_CAP >> era;
    }

    function gpuDayCap(uint256 dayIndex) public pure returns (uint256) {
        return gpuEpochCapForEra(eraForDay(dayIndex)) * EPOCHS_PER_DAY;
    }

    function cpuDayCap(uint256 dayIndex) public pure returns (uint256) {
        return cpuEpochCapForEra(eraForDay(dayIndex)) * EPOCHS_PER_DAY;
    }

    function settlementDigest(
        uint256 dayIndex,
        bytes32 merkleRoot,
        uint256 gpuDayReward,
        uint256 cpuDayReward,
        uint256 cumulativeGpu,
        uint256 cumulativeCpu
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                SETTLEMENT_TYPEHASH,
                dayIndex,
                merkleRoot,
                gpuDayReward,
                cpuDayReward,
                cumulativeGpu,
                cumulativeCpu
            )
        );

        return _hashTypedDataV4(structHash);
    }

    /// @notice Publishes one completed mining day.
    /// Day 0 is the first 24h following activateMining().
    /// Settlements MUST be sequential; unused capacity in a published day disappears.
    function publishMiningSettlement(
        uint256 dayIndex,
        bytes32 merkleRoot,
        uint256 gpuDayReward,
        uint256 cpuDayReward,
        uint256 cumulativeGpu,
        uint256 cumulativeCpu,
        bytes[] calldata signatures
    ) external {
        if (miningStart == 0) revert MiningNotActivated();
        if (dayIndex != settledDays) revert InvalidSettlementDay();
        if (merkleRoot == bytes32(0)) revert InvalidMerkleRoot();

        uint256 dayEnd =
            miningStart +
            ((dayIndex + 1) * MINING_DAY);

        if (block.timestamp < dayEnd) {
            revert SettlementDayNotCompleted();
        }

        if (gpuDayReward > gpuDayCap(dayIndex)) {
            revert GpuRewardCapExceeded();
        }

        if (cpuDayReward > cpuDayCap(dayIndex)) {
            revert CpuRewardCapExceeded();
        }

        uint256 expectedGpu =
            cumulativeGpuSettled +
            gpuDayReward;

        uint256 expectedCpu =
            cumulativeCpuSettled +
            cpuDayReward;

        if (
            cumulativeGpu != expectedGpu ||
            cumulativeCpu != expectedCpu
        ) revert WrongCumulativeTotals();

        uint256 cumulativeWork =
            cumulativeGpu +
            cumulativeCpu;

        if (cumulativeWork > WORK_SUPPLY_CAP) {
            revert WorkSupplyCapExceeded();
        }

        if (
            signatures.length < OPERATOR_THRESHOLD ||
            signatures.length > 3
        ) revert InsufficientOperatorApprovals();

        bytes32 digest = settlementDigest(
            dayIndex,
            merkleRoot,
            gpuDayReward,
            cpuDayReward,
            cumulativeGpu,
            cumulativeCpu
        );

        _requireOperatorThreshold(
            digest,
            signatures
        );

        settlements[dayIndex] = Settlement({
            merkleRoot: merkleRoot,
            gpuDayReward: gpuDayReward,
            cpuDayReward: cpuDayReward,
            cumulativeGpu: cumulativeGpu,
            cumulativeCpu: cumulativeCpu
        });

        cumulativeGpuSettled = cumulativeGpu;
        cumulativeCpuSettled = cumulativeCpu;
        settledDays = dayIndex + 1;

        emit MiningSettlementPublished(
            dayIndex,
            merkleRoot,
            gpuDayReward,
            cpuDayReward,
            cumulativeGpu,
            cumulativeCpu,
            eraForDay(dayIndex)
        );
    }

    /// @notice Claims cumulative mining entitlement from a published daily root.
    /// Anyone may relay the claim, but newly created EKNX ALWAYS go to `miner`.
    ///
    /// Leaf format uses OpenZeppelin StandardMerkleTree-style double hashing:
    /// keccak256(bytes.concat(keccak256(abi.encode(
    ///   miner, dayIndex, cumulativeGpu, cumulativeCpu
    /// ))))
    function claimMining(
        address miner,
        uint256 dayIndex,
        uint256 cumulativeGpu,
        uint256 cumulativeCpu,
        bytes32[] calldata merkleProof
    ) external {
        if (miner == address(0)) revert InvalidAddress();
        if (dayIndex >= settledDays) revert InvalidSettlementDay();

        bytes32 root =
            settlements[dayIndex].merkleRoot;

        bytes32 inner = keccak256(
            abi.encode(
                miner,
                dayIndex,
                cumulativeGpu,
                cumulativeCpu
            )
        );

        bytes32 leaf = keccak256(
            bytes.concat(inner)
        );

        bool valid = MerkleProof.verifyCalldata(
            merkleProof,
            root,
            leaf
        );

        if (!valid) revert InvalidMerkleProof();

        uint256 cumulativeEntitlement =
            cumulativeGpu +
            cumulativeCpu;

        uint256 alreadyClaimed =
            claimedEntitlement[miner];

        if (
            cumulativeEntitlement <=
            alreadyClaimed
        ) revert NothingToClaim();

        uint256 amount =
            cumulativeEntitlement -
            alreadyClaimed;

        uint256 nextWorkMinted =
            workMinted +
            amount;

        if (
            nextWorkMinted >
            WORK_SUPPLY_CAP
        ) revert WorkSupplyCapExceeded();

        if (
            totalSupply() + amount >
            MAX_SUPPLY
        ) revert MaxSupplyExceeded();

        uint256 totalSettled =
            cumulativeGpuSettled +
            cumulativeCpuSettled;

        if (
            nextWorkMinted >
            totalSettled
        ) revert WorkSupplyCapExceeded();

        claimedEntitlement[miner] =
            cumulativeEntitlement;

        workMinted =
            nextWorkMinted;

        _mint(
            miner,
            amount
        );

        emit MiningClaimed(
            miner,
            dayIndex,
            amount,
            cumulativeEntitlement
        );
    }

    function _requireOperatorThreshold(
        bytes32 digest,
        bytes[] calldata signatures
    ) internal view {
        address[3] memory approved;
        uint256 approvalCount;

        for (
            uint256 i = 0;
            i < signatures.length;
            ++i
        ) {
            address signer =
                ECDSA.recover(
                    digest,
                    signatures[i]
                );

            if (!isOperator[signer]) {
                continue;
            }

            for (
                uint256 j = 0;
                j < approvalCount;
                ++j
            ) {
                if (
                    approved[j] ==
                    signer
                ) {
                    revert DuplicateOperatorSignature();
                }
            }

            approved[approvalCount] =
                signer;

            ++approvalCount;

            if (
                approvalCount ==
                OPERATOR_THRESHOLD
            ) {
                return;
            }
        }

        revert InsufficientOperatorApprovals();
    }

    function enableTransfers() external {
        if (
            msg.sender !=
            marketContract
        ) {
            revert OnlyMarketContract();
        }

        if (!transfersEnabled) {
            transfersEnabled = true;

            emit TransfersEnabled(
                marketContract
            );
        }
    }

    /// @dev Before market graduation:
    /// - Genesis Market transfers are allowed.
    /// - Claims mint directly to miners.
    /// - Ordinary wallet-to-wallet EKNX transfers remain locked.
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        if (
            !transfersEnabled &&
            from != address(0) &&
            to != address(0) &&
            _msgSender() != marketContract
        ) {
            revert TransfersLocked();
        }

        super._update(
            from,
            to,
            value
        );
    }
}
