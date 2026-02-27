# 🚀 CLAW Token Testnet Deployment Guide

## Overview
Deploy $CLAW to Base Goerli (Testnet) for FREE.

**Time Required:** 30 minutes  
**Cost:** $0 (testnet ETH is free)  
**Skill Level:** Beginner

---

## Prerequisites

1. **Node.js** (v18 or higher)
2. **MetaMask** browser extension
3. **Git** (optional, for cloning)

---

## Step-by-Step Deployment

### Step 1: Install Dependencies (5 min)

```bash
# Navigate to project
cd claw-project

# Install packages
npm install

# Verify installation
npx hardhat --version
```

---

### Step 2: Setup Wallet (5 min)

1. **Open MetaMask**
2. **Add Base Goerli Network:**
   - Network Name: Base Goerli
   - RPC URL: https://goerli.base.org
   - Chain ID: 84531
   - Currency Symbol: ETH
   - Block Explorer: https://goerli.basescan.org

3. **Copy your wallet address**
   - Should look like: `0x1234...`
   - Save it for the faucet

---

### Step 3: Get Free Testnet ETH (5 min)

**Option A: Alchemy Faucet**
1. Visit: https://www.alchemy.com/faucets/base-sepolia
2. Connect wallet
3. Request 0.5 ETH (free, daily limit)

**Option B: QuickNode Faucet**
1. Visit: https://faucet.quicknode.com/base/goerli
2. Enter wallet address
3. Request ETH

**Verify:** Check MetaMask - should show ~0.5 ETH on Base Goerli

---

### Step 4: Configure Environment (2 min)

```bash
# Copy environment template
cp .env.example .env

# Edit .env file
nano .env
```

**Fill in:**
```
PRIVATE_KEY=your_metamask_private_key
BASESCAN_API_KEY=optional_for_now
```

**Get Private Key:**
- MetaMask -> Account Details -> Export Private Key
- Remove `0x` prefix if present
- ⚠️ **Never share this key!**

---

### Step 5: Deploy Contract (5 min)

```bash
# Compile contract
npm run compile

# Deploy to testnet
npm run deploy:testnet
```

**Expected Output:**
```
🚀 Deploying CLAW Token to Base Goerli...
Deploying with account: 0xYourAddress...
Account balance: 0.5 ETH
Deploying CLAWToken...
✅ CLAW Token deployed to: 0xContractAddress...
📊 View on BaseScan: https://goerli.basescan.org/address/0xContractAddress...
💾 Deployment info saved to deployment.json
```

---

### Step 6: Verify Contract (Optional, 3 min)

```bash
# Get contract address from deployment.json
npm run verify:testnet 0xYourContractAddress 0xYourWalletAddress
```

This makes the contract source code public and verifiable.

---

### Step 7: Test the Token (5 min)

**Add Token to MetaMask:**
1. Click "Import Tokens"
2. Paste contract address
3. Symbol: CLAW
4. Decimals: 18

**Test Transactions:**
- Send some CLAW to another testnet wallet
- Check tax distribution
- Verify auto-rewards

---

## 🎉 Success!

You now have:
- ✅ CLAW Token deployed on Base Goerli
- ✅ Verified contract (optional)
- ✅ Working token in MetaMask
- ✅ Ready for community testing

**Next Steps:**
1. Share contract address with community
2. Set up website on GitHub Pages
3. Create social media accounts
4. Start marketing

---

## 📋 Deployment Checklist

- [ ] Node.js installed
- [ ] Dependencies installed (`npm install`)
- [ ] MetaMask configured with Base Goerli
- [ ] Testnet ETH received (0.5+ ETH)
- [ ] `.env` file configured
- [ ] Contract compiled successfully
- [ ] Contract deployed
- [ ] Contract verified (optional)
- [ ] Token visible in MetaMask
- [ ] Test transactions completed

---

## 🆘 Troubleshooting

### "Insufficient funds"
- Get more testnet ETH from faucet
- Wait for transaction confirmations

### "Private key invalid"
- Ensure no `0x` prefix
- Ensure 64 characters
- Don't include quotes

### "Network not found"
- Add Base Goerli network manually in MetaMask
- Check Chain ID: 84531

### "Contract deployment failed"
- Check gas price (should be automatic)
- Ensure enough ETH for gas (~0.01 ETH)

---

## 📞 Support

**Questions? Issues?**
- Check BUILD_STATUS.md
- Review smart contract: CLAWToken.sol
- Read whitepaper: whitepaper.md

**Testnet Info:**
- Explorer: https://goerli.basescan.org
- Faucet: https://www.alchemy.com/faucets/base-sepolia
- RPC: https://goerli.base.org

---

**Red Shell = Green Candle** 🦞📈
