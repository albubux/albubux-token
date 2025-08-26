# Albubux (BUBX)

**Network:** BNB Smart Chain (BEP‑20)  
**Symbol:** BUBX  
**Total supply:** 400,000,000,000,000 BUBX (18 decimals)  
**Tax:** 0% buy / transfers, **1% sell** by default (sent to `feeReceiver`).

Albubux is a simple, fixed‑supply BEP‑20 token designed for transparency and ease of verification.
The contract uses OpenZeppelin libraries and applies a small sell fee only when tokens are sold to a DEX pair.

---

## 📦 Contents
- `contracts/Albubux.sol` – Solidity source code
- `LICENSE` – MIT
- `README.md` – this file

## 🔧 Key features
- Fixed supply minted at deployment (no further minting).
- 0% buy and wallet‑to‑wallet transfers.
- Optional sell‑fee (default 1%, capped at 3%) sent to a configurable `feeReceiver`.
- Owner can:
  - set/adjust `sellFeeBps` (max 3%),
  - update `feeReceiver`,
  - mark/unmark AMM pairs (e.g., PancakeSwap pair address),
  - exclude specific addresses from fees (owner/contract/receiver are excluded by default).

## 🧪 Compile / Verify
Use Remix or Hardhat with OpenZeppelin Contracts **v4.9** and Solidity `^0.8.19`.

### Remix (quickest)
1. Open https://remix.ethereum.org
2. Create `Albubux.sol` and paste the contents from `contracts/Albubux.sol`.
3. In the Solidity compiler:
   - Compiler version: `0.8.19`
   - Enable optimization (optional, 200 runs).
4. Deploy to **BSC** (testnet or mainnet) using an injected wallet (MetaMask).  
   **Constructor argument:** `feeReceiver` (your marketing/treasury wallet).

### After deploy (owner actions)
- Call `setAMMPair(pairAddress, true)` for your PancakeSwap pair to enable sell‑fee on DEX sells.
- If needed, adjust `setSellFeeBps(100)` (1% = 100 bps; max 300).
- Optionally update `setFeeReceiver(newWallet)`.
- Use `setFeeExempt(addr, true)` for presale contracts, liquidity locker, etc., if needed.

### BscScan verification
When verifying on BscScan:
- Compiler: `0.8.19`
- License: **MIT**
- Optimization: same settings as in deployment

> Tip: If using imports, enable “via‑IR” off and paste the file using Remix’s “Flatten” or Hardhat’s flatten plugins.

## ⚠️ Disclaimers
- This repository is provided **as is**, without warranty. Audit before mainnet use.
- Taxes above 3% are intentionally disallowed by code for investor safety.
- This token has no reflection/rebase/blacklist mechanics and no auto‑swap; the fee is a direct transfer to `feeReceiver`.

## 📝 License
MIT
