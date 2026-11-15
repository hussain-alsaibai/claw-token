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
- **Transaction:** `0xc6fff9f399066bb7fbfa5c509ff0e3160dc1e4856bd6249db68d1ba491b7a6cd`
- **Deployed:** Fri Feb 27, 2026 03:24 UTC


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

Note: `balanceOf` on the dead wallet **reverts** on this contract, which is the proof
that zero tokens have ever been burned. All 1,000,000,000 CLAW are still held by the
deployer.

---

## 🦞 About CLAW

AI-powered lobster meme token built on Base.

- **Total Supply:** 1,000,000,000 CLAW
- **Tax:** 5% (2% holders, 2% marketing, 1% burn)
- **Anti-whale:** Max wallet 2%
- **Auto-rewards:** Passive income for holders

**Tagline:** *Claw Your Way to the Moon*

---

## 📋 Tokenomics

| Allocation | Percentage |
|------------|------------|
| Liquidity | 50% |
| Marketing | 20% |
| Team | 15% (vested) |
| Community | 10% |
| Initial Burn | 5% |

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
