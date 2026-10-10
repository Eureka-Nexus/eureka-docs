# EKNX tokenomics

## Supply

- Maximum: 100,000,000 EKNX.
- Genesis: 1,000,000 EKNX, all allocated to the Genesis Market contract.
- Mining/work cap: 99,000,000 EKNX; these tokens are not pre-minted at genesis.
- Founder, team and deployer genesis token allocations: zero.

## Mining

Each accounting epoch lasts 60 seconds. Era-0 gross caps are 5 EKNX per GPU epoch and 0.8 EKNX per CPU epoch. There are 1,440 epochs per mining day; caps halve every 1,460 days after mining activation. Caps are ceilings, not guaranteed miner payouts. Rewards depend on validated, difficulty-weighted work and pool calibration.

The official pool fee is 1% of earned rewards: 99% to miners, 1% to `0x42f58c8a09bce3a00faf553aac60b0daf320858b`, with integer rounding handled by the server. Epoch rewards accumulate into daily cumulative Merkle settlements. Each on-chain daily settlement requires signatures from two of three contract operators.

The official automatic payout policy uses a 5 EKNX minimum published unpaid entitlement threshold. This is an operational pool policy, not a 5 EKNX restriction enforced by the token contract. Settlements are cumulative and published daily; automatic payout eligibility is checked every 4 hours at 00:30, 04:30, 08:30, 12:30, 16:30 and 20:30 UTC. The official relayer submits eligible `claimMining` transactions and pays the BSC gas, so the mining wallet does not need BNB for the official automatic payout flow.

## Genesis Market

The Genesis Market is LIVE on-chain. Of its 1,000,000 EKNX allocation, 650,000 EKNX are assigned to the live bonding curve and 350,000 EKNX are reserved for liquidity at graduation. Graduation targets 25 BNB: 21 BNB for liquidity, 3 BNB for operations and 1 BNB for founder revenue. These BNB allocations are separate from genesis token allocations.

Mining and the Genesis Market are both active. Transfer availability follows the deployed token and market contract rules. The future DEX stage remains inactive until graduation. No token price, return or earnings are guaranteed.
