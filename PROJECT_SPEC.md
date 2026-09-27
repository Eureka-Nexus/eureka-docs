# Eureka Nexus — Project Specification v0.1

## 1. Project

Name: Eureka Nexus  
Token: EKNX  
Network: Solana  
Official domain: eurekanexus.pt

Eureka Nexus is the ecosystem around the EKNX token, the Eureka Miner
and the future Eureka 1.0 AI Agent.

---

## 2. Maximum Supply

Maximum supply:

100,000,000 EKNX

No additional EKNX may be created after the mint authority is permanently revoked.

---

## 3. Token Distribution

Founder:
20,000,000 EKNX
20%

Mining Rewards:
50,000,000 EKNX
50%

Market / Bonding Curve / Liquidity:
15,000,000 EKNX
15%

Eureka Development:
10,000,000 EKNX
10%

Community / Partnerships:
5,000,000 EKNX
5%

TOTAL:
100,000,000 EKNX

---

## 4. Mining

Supported:

CPU Mining
GPU Mining

Not supported:

ASIC Mining

CPU and GPU use separate mining difficulty and reward accounting.

Initial reward allocation:

CPU:
60%

GPU:
40%

---

## 5. Mining Emission

Maximum mining emission during Year 1:

800,000 EKNX

CPU allocation:

480,000 EKNX

GPU allocation:

320,000 EKNX

Target round duration:

approximately 10 minutes

Approximate total reward per round:

15.22 EKNX

Approximate CPU reward:

9.13 EKNX

Approximate GPU reward:

6.09 EKNX

Rewards are distributed according to valid mining shares.

The emission schedule after Year 1 will be defined before public launch.

The maximum mining reserve can never exceed:

50,000,000 EKNX

---

## 6. Difficulty

CPU and GPU mining have independent difficulty.

Difficulty adjusts automatically according to network mining power.

More network hashrate:
difficulty increases.

Less network hashrate:
difficulty decreases.

Target:

approximately one mining round every 10 minutes.

Initial difficulty adjustment target:

every 2,016 rounds.

Approximately:

14 days.

---

## 7. CPU Mining

CPU mining will use a memory-hard Proof-of-Work algorithm designed
to reduce the advantage of specialized ASIC hardware.

RandomX is the current reference architecture.

Final implementation must be benchmarked and reviewed before launch.

---

## 8. GPU Mining

GPU mining will use a separate GPU-oriented Proof-of-Work implementation.

Target support:

NVIDIA
AMD

Final GPU algorithm:

TBD before release.

GPU and CPU miners must not compete directly in the same reward pool.

---

## 9. Eureka Miner

The official desktop application will be called:

Eureka Miner

Initial operating systems:

Windows
Linux later

The miner will detect available CPU and GPU hardware.

User options:

CPU ON/OFF
GPU ON/OFF

CPU modes:

Eco
Normal
Performance

The miner must display:

Wallet
CPU/GPU
Hashrate
Difficulty
Accepted shares
Rejected shares
Pending EKNX
Paid EKNX
Network status

---

## 10. User Wallets

Eureka Nexus will not require users to create a proprietary wallet.

Users use an existing Solana wallet.

Examples:

Phantom
Solflare
other compatible Solana wallets

The miner only needs the public Solana address.

The Eureka Miner must NEVER request:

Seed phrase
Private key
Wallet password

---

## 11. Mining Payments

Mining rewards are calculated by the Eureka Mining Server.

Flow:

Eureka Miner
→ mining challenge
→ valid share
→ reward accounting
→ payout
→ user's Solana wallet

Small rewards may accumulate before payout to avoid unnecessary blockchain transactions.

---

## 12. Project Wallet Separation

Separate wallets must exist for:

Founder
Mining Reserve
Market / Liquidity
Development
Community
Payout Hot Wallet

Private keys must never be stored in public repositories.

The mining payout server must not control the entire Mining Reserve.

---

## 13. Founder Allocation

Founder allocation:

20,000,000 EKNX

Founder allocation must be publicly disclosed.

A vesting / lock schedule will be defined before public trading begins.

---

## 14. Market

EKNX will initially be launched on Solana.

A portion of the market allocation may be used in a bonding-curve launch.

Initial bonding-curve allocation:

TBD

The project will not guarantee a future EKNX price.

The market determines the price through supply and demand.

---

## 15. Eureka 1.0

Eureka 1.0 is a future AI Agent within the Eureka Nexus ecosystem.

Initial public messaging:

COMING SOON — EUREKA 1.0

Eureka 1.0 is planned to evolve into an AI agent capable of using
tools and integrations to perform tasks for users.

Future EKNX utility may include:

AI compute
agent tasks
API usage
premium services
compute marketplace
developer services

These features must only be advertised as available once actually implemented.

---

## 16. Security Principles

Never store wallet seeds in source code.

Never store private keys in GitHub.

Use environment variables or secure secret storage.

Mining payouts use a limited hot wallet.

Treasury wallets remain separate.

Software releases must have cryptographic hashes.

Updates must eventually be digitally signed.

---

## 17. Repositories

eureka-miner
Desktop CPU/GPU mining software

eureka-mining-server
Mining pool, shares, difficulty and rewards

eknx-solana
Solana token and payout integration

eureka-website
Official Eureka Nexus website

eureka-docs
Official technical documentation

---

## 18. Initial Roadmap

Phase 1
Project identity and infrastructure

Phase 2
Eureka Miner CPU engine

Phase 3
Mining server and share validation

Phase 4
GPU mining

Phase 5
Solana EKNX integration

Phase 6
Automatic EKNX payouts

Phase 7
Public website and mining dashboard

Phase 8
EKNX Mainnet creation

Phase 9
Bonding curve / market launch

Phase 10
Public Eureka Miner release

Phase 11
Bitcointalk and community launch

Phase 12
Eureka 1.0 Agent development

---

Copyright © 2026 Eureka Nexus
