# Security

Never upload private keys, seed phrases, production configuration, operator signatures, wallet exports or `.env` files. Miner users supply only a public BSC address. The official mining-claim flow does not require the miner's seed phrase or private key; the relayer submits eligible claims and pays the BSC gas.

Verify release SHA-256 checksums. Checksums detect file changes; they are not publisher signatures. Current packages are not advertised as signed builds.

Keep miner dashboards and verifier daemons private. The pool and relayer must not store operator signing keys. Settlement publication requires two of the three immutable operators, checked against the deployed contract.

Back up persistent reward state and settlement files before any server upgrade. Do not reset the database to resolve startup errors. Do not kill a PID without confirming its executable and ownership.

Mining activation has already occurred on BNB Smart Chain. Genesis Market launch remains a separate one-time action and must only be executed after read-only preflight and explicit approval.

Report exploitable issues through GitHub private vulnerability reporting where available. Never include secrets in a public issue. These checks are not an independent security audit of the contracts or protocol.
