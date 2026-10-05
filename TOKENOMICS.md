# EKNX tokenomics

## Supply

- Maximum: 100,000,000 EKNX.
- Genesis: 1,000,000 EKNX, all allocated to the Genesis Market contract.
- Mining/work cap: 99,000,000 EKNX; these tokens are not pre-minted at genesis.
- Founder, team and deployer genesis token allocations: zero.

## Mining

Each accounting epoch lasts 60 seconds. Era-0 gross caps are 5 EKNX per GPU epoch and 0.8 EKNX per CPU epoch. There are 1,440 epochs per mining day; caps halve every 1,460 days after mining activation. Caps are ceilings, not guaranteed miner payouts. Rewards depend on validated, difficulty-weighted work and pool calibration.

The official pool fee is 1% of earned rewards: 99% to miners, 1% to `0x42f58c8a09bce3a00faf553aac60b0daf320858b`, with integer rounding handled by the server. Epoch rewards accumulate into daily cumulative Merkle settlements. Each on-chain daily settlement requires signatures from two of three contract operators.

The official client/pool uses a 50 EKNX minimum claim policy. This is not a 50 EKNX restriction enforced by the token contract. Claims require an available published settlement and a valid Merkle proof. The official Eureka Nexus Relayer submits eligible claims and pays the BSC gas, so the mining wallet does not need BNB for the official claim flow.

## Genesis Market

The separate market launch enables the bonding curve. Of its 1,000,000 EKNX allocation, 650,000 EKNX are assigned to the curve sale and 350,000 EKNX to liquidity. Graduation targets 25 BNB: 21 BNB for liquidity, 3 BNB for operations and 1 BNB for founder revenue. These BNB allocations are separate from genesis token allocations.

Mining activation does not launch the market. Transfer availability follows the token and market contract rules. No token price, return or earnings are guaranteed.
