# Launch checklist

Status date: 2026-10-05 (Europe/Lisbon). This checklist is a release gate, not a claim that every item has passed.

## Current production status

- [x] Canonical BSC token and Genesis Market addresses agree across miner, server and public documentation.
- [x] Official Miner v1.1.2 is publicly released with SHA-256 checksums for Windows and Linux artifacts.
- [x] Official Miner v1.1.2 and Mining Server v1.0.1 are the current public/production release lines.
- [x] Pool health, network and public statistics endpoints respond over HTTPS.
- [x] On-chain mining is active. Production verifies `miningStart = 1790996796`. Genesis Market state remains separate and must be checked independently on-chain.

## Remaining production verification and hardening

- [x] Mining Server v1.0.1 is deployed on the production VPS; commit and executable SHA-256 are recorded.
- [ ] Verify verifier health and Stratum ingress from outside the server, including real supported GPU hardware.
- [ ] Repeat and record controlled valid/invalid/duplicate CPU and GPU share tests against the current production-compatible stack.
- [ ] Rehearse settlement generation, two-of-three operator signing, publication and claim on an isolated EVM; verify the contract digest and proof format.
- [ ] Verify recovery from a consistent backup of state and settlements.
- [ ] Add external uptime monitoring and automated off-site backup verification; continue monitoring disk capacity, time synchronization and RPC reliability.
- [ ] Verify deployed-bytecode equivalence against the published source snapshot and complete independent security review requirements.
- [ ] Complete final wallet/network/claim/market user-flow review. The public website is already updated with current addresses and releases.
- [ ] Re-check Genesis Market state immediately before any launch action and record explicit approval of every irreversible transaction.

Do not fill these checkboxes based only on a successful build or `/health` response. Public release availability does not prove production readiness.

## Current milestones

1. Official Miner v1.1.2 and Mining Server v1.0.1 are versioned; production backups, rollback copies and service watchdogs are in place.
2. Mining activation is complete. Production verifies the on-chain mining start timestamp `1790996796` and Mining Server v1.0.1 uses it as the authoritative mining clock.
3. The public website is published with canonical BSC addresses, Miner v1.1.2, the official X account and official project email.
4. Continue monitoring accepted CPU/GPU work, accounting epochs and daily settlements.
5. The first real end-to-end claim with at least 50 EKNX remains a required production milestone and must not be marked complete until confirmed on-chain.
6. Genesis Market launch remains separate; verify `launched()` and transfer rules immediately before any explicitly approved launch action.

Never manually fabricate a production mining timestamp, erase reward state, or bypass the on-chain gate to make the UI look live.
