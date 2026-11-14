# 🦞 CLAW Token — Launch Checklist

Last updated: 2026-03-01

---

## ✅ DONE (AI-managed)

- [x] Smart contract written (`src/CLAWToken.sol`)
- [x] Contract bugs fixed (tax logic, max wallet, removed marketing wallet)
- [x] 17/17 unit tests passing (`forge test`)
- [x] Deploy scripts ready (`scripts/deploy-sepolia.sh`, `scripts/deploy-mainnet.sh`)
- [x] Foundry project configured (`foundry.toml`)
- [x] Website live (GitHub Pages)
- [x] Whitepaper written
- [x] 46 days of daily social content pre-loaded
- [x] 32 meme concepts (3 batches)
- [x] 7-tweet launch thread
- [x] Influencer outreach scripts (3 tiers)
- [x] DEX listing submission guide (4 platforms)
- [x] Community FAQ (20+ Q&As)
- [x] AMA script (60 min)
- [x] Community growth playbook (0→1K members)
- [x] Newsletter outreach (8 publications)
- [x] Social profile copy (Twitter, Telegram, Discord, CMC, CoinGecko)
- [x] Press release draft
- [x] Mainnet readiness document with cost breakdown
- [x] Contract audit notes

---

## 🔴 REQUIRES HUMAN ACTION

### Step 1 — Social Accounts (~45 min total)
- [ ] Create Twitter/X: `@CLAWTokenBase`
  - Profile copy ready: `content/social-profile-copy.md`
  - Post 5 sequential launch tweets on Day 1
- [ ] Create Telegram group: `t.me/CLAWToken`
  - Welcome message + rules ready: `content/social-profile-copy.md`

### Step 2 — Logo (~2–4 hrs or outsource)
- [ ] Design CLAW logo (400×400 PNG, transparent bg)
  - Lobster character, red/vibrant, crypto-themed
  - Needed for: Twitter, Telegram, DEX listings, CMC, CoinGecko

### Step 3 — Testnet Redeployment (30 min)
- [ ] Get testnet ETH on Tenderly Virtual TestNet:
  - https://faucet.quicknode.com/base/sepolia
  - https://www.alchemy.com/faucets/base-sepolia
- [ ] Run: `PRIVATE_KEY=0x... bash scripts/deploy-sepolia.sh`
  - Redeploys the **fixed** contract (old one had broken tax logic)
- [ ] Update website with new testnet address

### Step 4 — Mainnet Launch (~1 hr + capital)
- [ ] Bridge ETH to Base mainnet (via https://bridge.base.org)
  - Minimum needed: ~0.005 ETH gas + $100–500 initial liquidity
- [ ] Run: `PRIVATE_KEY=0x... BASESCAN_API_KEY=... bash scripts/deploy-mainnet.sh`
  - Will prompt: "Type 'LAUNCH THE LOBSTER' to confirm"
- [ ] Add liquidity on Uniswap v3 (Base)
- [ ] Register Uniswap pool: `setAmmPair(<pool_address>, true)`
- [ ] Lock LP tokens on Unicrypt
- [ ] Fire launch tweet thread
- [ ] Submit to DEX Screener + DexTools
- [ ] Update website with mainnet address

### Step 5 — Exchange Listings (Week 2)
- [ ] Submit to CoinGecko
- [ ] Submit to CoinMarketCap
- [ ] Begin influencer outreach

---

## 💰 Cost Summary

| Item | Cost |
|------|------|
| Social accounts | Free |
| Logo (DIY: Canva/Figma) | Free |
| Logo (outsource: Fiverr) | $10–50 |
| Tenderly Virtual TestNet testnet ETH | Free (faucet) |
| Base Mainnet gas | ~$15 |
| Initial liquidity | $100–500 (your choice) |
| LP lock (Unicrypt) | ~$6 |
| **Total minimum** | **~$121–571** |

---

## ⚡ Fastest Path to Launch

1. Create Twitter + Telegram (tonight, 45 min)
2. Get testnet ETH + redeploy fixed contract (30 min)
3. Get logo made (Canva or Fiverr, 1–4 hrs)
4. When ready: fund wallet, run mainnet deploy script, fire content

The machine is loaded. Just needs the trigger. 🦞
