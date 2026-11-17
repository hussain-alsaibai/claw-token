# 🦞 $CLAW Token

**AI-Powered Lobster Meme Coin - TESTNET (Tenderly Virtual TestNet)**

[![Status](https://img.shields.io/badge/Status-TESTNET-yellow)](#)
[![Contract](https://img.shields.io/badge/Contract-Deployed%20(testnet)-blue)](#)
[![Network](https://img.shields.io/badge/Network-Tenderly%20VNet-purple)](#)

## 🚀 DEPLOYED (TESTNET)

**Contract Address:** `0x6ae6829d87eEaE1fFF4006E8BB310f4e92546cB1`

**Explorer:** https://dashboard.tenderly.co/Alsaibai/project/project/vnet/claw-token-vnet/contracts/0x6ae6829d87eEaE1fFF4006E8BB310f4e92546cB1

**Website:** https://hussain-alsaibai.github.io/claw-token/

**GitHub:** https://github.com/hussain-alsaibai/claw-token


> ⚠️ **This is a testnet token with no monetary value.** It is deployed on a Tenderly
> Virtual TestNet, not on Base mainnet or Base Sepolia. It cannot be traded, has no
> liquidity, and is not audited. All 1,000,000,000 CLAW are held by the deployer and
> **zero have been burned** — the dead wallet balance is 0.

---

## 🎉 Deployment Confirmed

- **Network:** Tenderly Virtual TestNet (Base-Sepolia-compatible, chain ID 84532)
- **Chain ID:** 84532
- **Status:** ✅ Verified and Live
- **Deployment transaction:** `0x951ea93f11c4af4dc6637bd49d8ef2282f9d80eb8ddf57a99ed80d6e763bf126`
- **Deployed:** Tue Nov 11, 2026 06:37 UTC
- **Deployer / owner:** `0x16f6d1d4b67019f5a7eadfc151430c50cbc1244c`
- **Superseded contract:** `0xA43162888cc51E535eb16d60609C289Ac2882bA7` (deployed 2026-02-28, 3170 bytes) — its `burnBps`, `rewardBps` and `totalTaxBps` all revert, so it is an older version of the token. Use the address above.


### Verify it yourself

This token lives on a **Tenderly Virtual TestNet**, which is a separate chain from
public Base. If you query a public Base RPC for this address you will correctly get
**0 bytes of code** — that is the wrong network, not a missing contract.

```bash
RPC=https://virtual.base-sepolia.eu.rpc.tenderly.co/7360d884-4b4b-4385-a8b7-4d02aebc1c72
curl -s -X POST -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","method":"eth_getCode","params":["0x6ae6829d87eEaE1fFF4006E8BB310f4e92546cB1","latest"],"id":1}' \
  $RPC
```

You should get ~4541 bytes of code. `eth_chainId` returns `0x14a34` (84532).

**Zero CLAW has been burned on this contract.** `balanceOf` on the dead wallet
(`0x000000000000000000000000000000000000dEaD`) returns **0** — it does *not* revert here.
The single mint event moved all 1,000,000,000 CLAW from the zero address to the deployer,
`totalSupply` is still 1,000,000,000, and the deployer holds the full supply.

One caveat worth stating plainly: the **superseded** contract above did mint 10,000,000 CLAW
straight to the dead wallet in its constructor. That is 1% of supply, it was never a
burn — nothing was destroyed — and it has no effect on the contract you are using. But if
you see “10M burned” anywhere, that is where the number came from.

---

## 🦞 About CLAW

AI-powered lobster meme token built on Base.

- **Total Supply:** 1,000,000,000 CLAW
- **Tax:** 3% total (2% burn, 1% reward pool)
- **Anti-whale:** Max wallet 2%
- **Auto-rewards:** 1% reward pool (currently set to the burn address, so it burns too)

**Tagline:** *Claw Your Way to the Moon*

---

## 📋 Tokenomics

| Allocation | Percentage |
|------------|------------|
| Liquidity | 50% |
| Marketing | 20% |
| Team | 15% (vested) |
| Community | 10% |
| Burned so far | 0% (no transfers have occurred) |

---

## 🔗 Links

- 🌐 **Website:** https://hussain-alsaibai.github.io/claw-token/
- 📄 **Whitepaper:** [whitepaper.md](whitepaper.md)
- 🔍 **Explorer:** https://dashboard.tenderly.co/Alsaibai/project/project/vnet/claw-token-vnet/contracts/0x6ae6829d87eEaE1fFF4006E8BB310f4e92546cB1
- 💬 **Telegram:** `t.me/CLAWToken` — *handle not yet claimed*
- 🐦 **Twitter:** `@CLAWTokenBase` — *handle not yet claimed*

---

## 🎨 Brand

- **Colors:** Red (#FF4136) + Gold (#FFD700)
- **Mascot:** AI-powered lobster with diamond claws
- **Emoji:** 🦞
- **Hashtags:** #CLAW #Base #MemeCoin

---

## ⚠️ Disclaimer

This is a meme token for entertainment purposes. Not financial advice. DYOR.

---

**Red Shell = Green Candle** 🦞📈

*Deployed autonomously by OpenClaw AI*
