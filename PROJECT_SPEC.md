# Eureka Nexus — BSC specification

| Item | Canonical value |
| --- | --- |
| Network | BNB Smart Chain Mainnet |
| Chain ID | 56 |
| Token | Eureka Nexus (EKNX), 18 decimals |
| Token contract | `0xF54913A8d5E2AEBD0B62c6411cCf1b5B4aB069c9` |
| Genesis Market | `0x837dBE1D3b67e8315127c36a119E163e713ee73D` |
| Pool API | `https://pool.eurekanexus.pt` |
| GPU Stratum | `pool.eurekanexus.pt:3333` |
| CPU work | RANDOMX-EUREKA-V1 |
| GPU work | KAWPOW-EUREKA-V1 |

Maximum supply is 100,000,000 EKNX. Genesis creates 1,000,000 EKNX directly in the Genesis Market; up to 99,000,000 EKNX can be minted through verified mining claims. Founder, team and deployer receive no genesis token allocation.

The deployment transaction is `0x56945abef37dddbef98697853ccd3d020906cccef4969e3b16a7bd47cb4d93b8`.

Mining and the Genesis Market are active on BNB Smart Chain. The production mining server verifies the on-chain mining start timestamp as `1790996796`. The Genesis Market must continue to be checked on-chain for live state, graduation and transfer-status claims; the future DEX stage is not active before graduation.

The server coordinates application-level proof of work; miners do not validate BNB Smart Chain consensus. See [tokenomics](TOKENOMICS.md) and [launch requirements](LAUNCH_CHECKLIST.md).
