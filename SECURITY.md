# Security

Never upload private keys, seed phrases, production configuration, operator signatures, wallet exports or `.env` files. Miner users supply only a public BSC address. The official automatic payout flow does not require the miner's seed phrase or private key; eligible published entitlement is claimed by the server-side relayer, which pays the BSC gas.

Verify release SHA-256 checksums. Checksums detect file changes; they are not publisher signatures. Current packages are not advertised as signed builds.

Keep miner dashboards and verifier daemons private. The pool and relayer must not store operator signing keys. Settlement publication requires two of the three immutable operators, checked against the deployed contract.

Back up persistent reward state and settlement files before any server upgrade. Do not reset the database to resolve startup errors. Do not kill a PID without confirming its executable and ownership.

Mining and the Genesis Market are already active on BNB Smart Chain. The future DEX stage remains inactive until graduation and must be handled only after read-only verification of the applicable on-chain state and operational gates.

Report exploitable issues through GitHub private vulnerability reporting where available. Never include secrets in a public issue. These checks are not an independent security audit of the contracts or protocol.
