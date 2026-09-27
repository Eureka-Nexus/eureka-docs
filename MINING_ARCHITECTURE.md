# Mining Architecture

```text
Eureka Miner → shares → Eureka Mining Server → reward ledger → Solana payout service → miner wallet
```

The miner sends a **public Solana address only**. Private keys never belong on the mining server.

The current SHA-256 protocol engine validates the end-to-end pipeline. It must not be represented as the final anti-ASIC CPU algorithm. Final CPU and GPU PoW algorithms must be frozen, benchmarked and reviewed before public mining launch.
