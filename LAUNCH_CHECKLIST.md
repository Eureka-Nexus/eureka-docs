# Launch checklist

Status date: 2026-10-10 (Europe/Lisbon). This checklist is an audit/readiness record, not a claim that every item has passed.

## Current production status

- [x] Canonical BSC token and Genesis Market addresses agree across miner, server and public documentation.
- [x] Official Miner technical release v2026.1.2 is publicly released with SHA-256 checksums for Windows and Linux artifacts.
- [x] Official Miner technical release v2026.1.2 is public. Canonical Mining Server source is tagged v1.0.3 at commit `199df42eb8cd13b377384e6119e340a9e3547f1b`; production VPS runtime/version verification remains a separate deployment check.
- [x] Pool health, network and public statistics endpoints respond over HTTPS.
- [x] On-chain mining is active and the Genesis Market is LIVE on BNB Smart Chain. The future DEX stage remains inactive until the on-chain graduation conditions are met.

## Remaining production verification and hardening

- [ ] Verify the production VPS runtime binary/version against canonical Mining Server v1.0.3 and record the deployed executable SHA-256.
- [ ] Verify verifier health and Stratum ingress from outside the server, including real supported GPU hardware.
- [ ] Repeat and record controlled valid/invalid/duplicate CPU and GPU share tests against the current production-compatible stack.
- [ ] Rehearse settlement generation, two-of-three operator signing, publication and claim on an isolated EVM; verify the contract digest and proof format.
- [ ] Verify recovery from a consistent backup of state and settlements.
- [ ] Add external uptime monitoring and automated off-site backup verification; continue monitoring disk capacity, time synchronization and RPC reliability.
- [ ] Verify deployed-bytecode equivalence against the published source snapshot and complete independent security review requirements.
- [ ] Complete final wallet/network/claim/market user-flow review. The public website is already updated with current addresses and releases.
- [ ] Continue monitoring the live Genesis Market and verify graduation, transfer and DEX-transition conditions before any irreversible post-graduation action.

Do not fill these checkboxes based only on a successful build or `/health` response. Public release availability does not prove production readiness.

## Current milestones

1. Official Miner technical release v2026.1.2 and canonical Mining Server source v1.0.3 are versioned. Production VPS runtime/version verification for the server remains an explicit audit item.
2. Mining activation is complete. Production verifies the on-chain mining start timestamp `1790996796`; the server uses the token `miningStart()` as the authoritative mining clock.
3. The public website is published with canonical BSC addresses, Miner technical release v2026.1.2, the official X account and official project email.
4. Continue monitoring accepted CPU/GPU work, accounting epochs and daily settlements.
5. A real end-to-end mining payout has already been confirmed on-chain. Current automatic payout eligibility is based on at least 5 EKNX of published unpaid entitlement.
6. The Genesis Market is LIVE on-chain. Continue monitoring `launched()`, graduation state and transfer rules; the future DEX stage is not active before graduation.

Never manually fabricate a production mining timestamp, erase reward state, or bypass the on-chain gate to make the UI look live.
