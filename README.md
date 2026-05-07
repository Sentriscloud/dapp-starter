# Sentrix dApp Starter

[![CI](https://github.com/Sentriscloud/dapp-starter/actions/workflows/ci.yml/badge.svg)](https://github.com/Sentriscloud/dapp-starter/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/Sentriscloud/dapp-starter)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/Sentriscloud/dapp-starter?include_prereleases&sort=semver)](https://github.com/Sentriscloud/dapp-starter/releases/latest)


Minimal end-to-end project for shipping a dApp on **Sentrix Chain** (chain ID `7119` mainnet, `7120` testnet) — deploys a small ERC-20 from a Foundry script, wraps native SRX into WSRX, reads it back with viem, and verifies the contract source against the self-hosted Sourcify at `verify.sentrixchain.com`.

If you can deploy on Ethereum, you can deploy on Sentrix — Sentrix runs an embedded `revm 38` interpreter so every Solidity / Vyper contract that targets Cancun-era EIPs works with no Sentrix-specific changes.

## What you'll build in this starter

1. **`SentrixDemoToken`** — a 1M-supply ERC-20 you mint to your deploy wallet.
2. **WSRX wrap demo** — deposit native SRX into the canonical `WSRX` contract and read the wrapped balance back.
3. **Sourcify verification** — submit your `SentrixDemoToken` source so it shows up green-checkmarked on `scan.sentrixchain.com`.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/) (`forge`, `cast`)
- Node 22+ + `pnpm` for the viem read-side script
- A funded wallet on testnet — grab tSRX from [`faucet.sentrixchain.com`](https://faucet.sentrixchain.com)

## Project layout

```
.
├── contracts/
│   └── SentrixDemoToken.sol        # ERC-20 (OpenZeppelin)
├── script/
│   ├── Deploy.s.sol                # Foundry deploy
│   └── WrapSrx.s.sol               # Native SRX → WSRX wrap demo
├── scripts/
│   └── read-balance.ts             # viem read-side smoke test
├── test/
│   └── SentrixDemoToken.t.sol      # `forge test` — mint + transfer + permit
├── foundry.toml
├── remappings.txt
├── package.json
└── .env.example
```

## Run it

```bash
# 1. Install deps
forge install OpenZeppelin/openzeppelin-contracts --no-commit
pnpm install

# 2. Configure
cp .env.example .env
# Edit .env: set DEPLOY_PRIVATE_KEY (NEVER commit this) + RPC_URL

# 3. Deploy + wrap
forge build
forge test
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --legacy
forge script script/WrapSrx.s.sol --rpc-url $RPC_URL --broadcast --legacy

# 4. Read it back
pnpm read

# 5. Verify on Sourcify (testnet 7120 example)
forge verify-contract \
  --verifier sourcify \
  --verifier-url https://verify.sentrixchain.com \
  --chain 7120 \
  <DEPLOYED_ADDRESS> \
  contracts/SentrixDemoToken.sol:SentrixDemoToken
```

## Network details

Pulled from `https://sentrixchain.com/chain.json`. Drop these into MetaMask, ethers, viem, or any tool that knows about `eth_chainId`:

|   | Mainnet | Testnet |
|---|---|---|
| Chain ID | `7119` | `7120` |
| RPC | `https://rpc.sentrixchain.com` | `https://testnet-rpc.sentrixchain.com` |
| WS | `wss://rpc.sentrixchain.com/ws` | `wss://testnet-rpc.sentrixchain.com/ws` |
| Explorer | `https://scan.sentrixchain.com` | `https://scan.sentrixchain.com` |
| Verifier (Sourcify) | `https://verify.sentrixchain.com` | `https://verify.sentrixchain.com` |
| WSRX | `0x4693b113e523A196d9579333c4ab8358e2656553` | `0x85d5E7694AF31C2Edd0a7e66b7c6c92C59fF949A` |
| Multicall3 | `0xFd4b34b5763f54a580a0d9f7997A2A993ef9ceE9` | `0x7900826De548425c6BE56caEbD4760AB0155Cd54` |
| TokenFactory | `0xc753199b723649ab92c6db8A45F158921CFDEe49` | `0x7A2992af0d4979aDD076347666023d66d29276Fc` |
| SentrixSafe (1-of-1 authority) | `0x6272dC0C842F05542f9fF7B5443E93C0642a3b26` | `0xc9D7a61D7C2F428F6A055916488041fD00532110` |

## Notes on Sentrix-specific behaviour

- **`--legacy` flag** on `forge script` because the public RPC currently rejects EIP-1559 transactions during the early-launch window. Will lift once gas-price oracles stabilise.
- **8-decimal native ledger, 18-decimal EVM view.** Sentrix's underlying ledger is BTC-style 8-decimal (1 SRX = 100,000,000 sentri). EVM tooling sees the standard 18-decimal wei-scaled view — `eth_getBalance` returns `balance * 1e10` so MetaMask + ethers + viem display correctly without any Sentrix-specific config.
- **`debug_traceTransaction` is not exposed.** The chain doesn't currently serve the trace surface; tools that depend on it (Tenderly, etc.) won't work. Standard event logs + receipts cover most use cases.
- **Block time = 1 second.** Plan your gas / mempool assumptions accordingly.
- **Finality = 2/3+1 stake-weighted precommit supermajority.** A block is "justified" when its precommits cross 2/3+1 and "finalized" when a descendant block is justified. For exchange / bridge integrations: wait for **finalized**, not just included.

## License

MIT — copy and modify freely.
