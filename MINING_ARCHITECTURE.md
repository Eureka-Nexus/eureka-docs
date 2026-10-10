# Mining architecture

```text
Miner CPU (RandomX) / GPU (external KAWPOW engine)
  -> official HTTP pool / KAWPOW Stratum bridge
  -> local proof-of-work verifiers
  -> difficulty-weighted epoch accounting
  -> daily cumulative Merkle settlement
  -> two-of-three operator signatures
  -> BSC settlement publication
  -> automatic payout scheduler checks published unpaid entitlement every 4 hours
  -> official relayer submits eligible claimMining transactions and pays BSC gas
```

Only server-validated work creates accounting rewards. Reported hashrate is not proof of work. The server stores public BSC wallet addresses and must not hold miner seed phrases or operator signing keys.

Production uses the token's `miningStart()` as its authoritative clock. Keep configuration `mining_start_unix` at zero; a positive local timestamp is a legacy test override and must not be used in production. A pool can report its acceptance/emission flags as true while still waiting for on-chain activation.

The server persists accounts and epoch state under `data/`, and settlements under `data/settlements/`. These are financial records, not disposable build artifacts. A restore must preserve a consistent snapshot. The server rejects malformed reward state rather than silently creating an empty ledger.

KAWPOW and RandomX verifiers must listen on loopback only. Expose the HTTP API through HTTPS and the intended Stratum listener through its controlled ingress. Keep administrative access and operator signing separate.

The official Eureka Nexus Miner technical release v2026.1.2 dashboard is `http://127.0.0.1:8077`. The dashboard is a local service and must not be exposed publicly.
