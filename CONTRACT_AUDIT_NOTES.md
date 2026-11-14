# CLAWToken.sol — Internal Audit Notes

Last reviewed: 2026-03-01

## 🔴 CRITICAL: Tax Logic Only Fires for Owner Transactions

### The Bug

```solidity
if (!isExcludedFromTax[from] && !isExcludedFromTax[to]) {
    if (from == owner()) {         // ← sell tax
        taxAmount = (value * sellTax) / 100;
    } else if (to == owner()) {    // ← buy tax
        taxAmount = (value * buyTax) / 100;
    }
    // ← ALL other transfers: taxAmount stays 0
}
```

The tax only applies when `from == owner()` (owner selling) or `to == owner()` (owner buying).

**Regular wallet-to-wallet transfers: no tax.**
**DEX swaps (Uniswap pool ↔ user): no tax** (unless pool address IS the owner).

This means auto-rewards, burn, and marketing wallet only get funded when **the owner specifically transacts** — not on regular trading volume.

### What Should Happen

Tax should fire on ALL non-excluded transfers (the standard meme coin pattern):

```solidity
if (!isExcludedFromTax[from] && !isExcludedFromTax[to]) {
    taxAmount = (value * transferTax) / 100;
    // distribute to holders/burn/marketing
}
```

Or differentiate buy (from = liquidity pool) vs sell (to = liquidity pool) using a DEX pair mapping.

---

## 🟡 DISCREPANCY: Documented vs Actual Tokenomics

| | Marketed | Contract |
|--|---------|---------|
| Total tax | 3% | 5% buy / 5% sell |
| Holder rewards | 2% | 2% (40% of 5%) |
| Marketing | None mentioned | 2% (40% of 5%) |
| Burn | 1% | 1% (20% of 5%) |

The marketing wallet cut was never mentioned in the whitepaper or social content.
Either remove it (send to holders or burn) or document it honestly.

---

## 🟡 MISSING: Anti-Whale Mechanism

The whitepaper and all content mentions "2% max wallet protection."
**This is not in the contract.** There is no `maxWalletAmount` check anywhere.

To add it:
```solidity
uint256 public maxWalletAmount = TOTAL_SUPPLY * 2 / 100; // 2%

function _update(...) {
    // after tax calculation, before transfer:
    if (to != owner() && to != address(this)) {
        require(
            balanceOf(to) + (value - taxAmount) <= maxWalletAmount,
            "Exceeds max wallet"
        );
    }
}
```

---

## 🟡 MISSING: Auto-Redistribution to Holders

Content promises "2% automatically redistributed to all holders."
The contract sends 40% of tax to `address(this)` (the contract itself) — NOT to individual holders.

Without a distribution function, these tokens sit in the contract forever. 

Options:
1. Use a reflection mechanism (RFI pattern — complex)
2. Send to a staking/rewards contract
3. Send to dead wallet (simplest — just increase burn percentage)
4. Add `distributeRewards()` function that loops holders (gas-expensive, not scalable)

**Recommendation:** For a meme coin launch, simplest fix is to redirect the 40% "holder share" to either burn or a claimable rewards pool. The reflection pattern requires significant refactoring.

---

## Recommended Actions Before Mainnet

### Option A — Quick Fix (Deploy-Ready in ~2 hours)
1. Fix tax logic to fire on ALL non-excluded transfers
2. Remove marketing wallet (redirect to burn for cleaner story)
3. Add max wallet limit
4. Accept that auto-redistribution = increased burn (simpler, honest)
5. Update all content to say "3% burn" instead of "2% rewards + 1% burn"

### Option B — Full Refactor (3-5 hours)
1. Implement proper buy/sell tax with LP pair detection
2. Add reflection mechanism (RFI pattern) for true auto-redistribution
3. Add max wallet limit
4. Match contract exactly to whitepaper claims

### Option C — Use Existing Template
Deploy a battle-tested meme coin template (e.g., from Token Sniffer's verified list)
and customize name/symbol/supply. Fastest path to a working contract.

---

## Summary

The contract as-is **will not generate rewards or burn on normal trading.**
This needs to be fixed before mainnet or the core value proposition doesn't work.

**This is fixable. But it needs to be fixed before mainnet deploy.**

Flagging for The Architect's attention.
