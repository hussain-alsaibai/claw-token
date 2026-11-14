#!/bin/bash
# CLAW Token — Deploy to Base Mainnet via Foundry
# Usage: PRIVATE_KEY=0x... BASESCAN_API_KEY=... bash scripts/deploy-mainnet.sh
#
# ⚠️  THIS DEPLOYS REAL TOKENS WITH REAL ETH — DOUBLE CHECK EVERYTHING ⚠️

set -e

echo "🦞 CLAW Token — Base MAINNET Deploy"
echo "======================================"
echo "⚠️  WARNING: This is MAINNET. Real ETH. Real tokens."
echo ""
read -p "Type 'LAUNCH THE LOBSTER' to confirm: " CONFIRM
if [ "$CONFIRM" != "LAUNCH THE LOBSTER" ]; then
  echo "Aborted."
  exit 1
fi

if [ -z "$PRIVATE_KEY" ]; then
  echo "❌ Error: Set PRIVATE_KEY environment variable"
  exit 1
fi

if [ -z "$BASESCAN_API_KEY" ]; then
  echo "⚠️  No BASESCAN_API_KEY — contract won't be auto-verified"
fi

FORGE="/home/node/.foundry/bin/forge"
CAST="/home/node/.foundry/bin/cast"
RPC="https://mainnet.base.org"

DEPLOYER=$($CAST wallet address --private-key $PRIVATE_KEY)
echo "Deployer: $DEPLOYER"
BALANCE=$($CAST balance $DEPLOYER --rpc-url $RPC)
echo "Balance:  $BALANCE ETH"
echo ""

echo "📦 Building contract..."
$FORGE build --quiet

echo "🚀 Deploying CLAWToken to Base Mainnet..."

VERIFY_FLAG=""
if [ -n "$BASESCAN_API_KEY" ]; then
  VERIFY_FLAG="--verify --etherscan-api-key $BASESCAN_API_KEY"
fi

DEPLOY_OUTPUT=$($FORGE script script/Deploy.s.sol:DeployScript \
  --rpc-url $RPC \
  --private-key $PRIVATE_KEY \
  --broadcast \
  $VERIFY_FLAG \
  2>&1)

echo "$DEPLOY_OUTPUT"

CONTRACT=$(echo "$DEPLOY_OUTPUT" | grep "CLAW Token deployed at:" | awk '{print $NF}')

if [ -n "$CONTRACT" ]; then
  echo ""
  echo "🎉 CLAW Token is LIVE on Base Mainnet!"
  echo "   Contract: $CONTRACT"
  echo "   Explorer: https://basescan.org/address/$CONTRACT"
  echo ""

  cat > deployment-mainnet.json << EOF
{
  "contractAddress": "$CONTRACT",
  "deployer": "$DEPLOYER",
  "network": "base-mainnet",
  "chainId": 8453,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "rpc": "$RPC",
  "explorerUrl": "https://basescan.org/address/$CONTRACT",
  "tokenomics": {
    "totalSupply": "1000000000",
    "burnBps": 200,
    "rewardBps": 100,
    "totalTaxBps": 300,
    "maxWalletPct": 2
  }
}
EOF

  echo "📝 POST-DEPLOY CHECKLIST:"
  echo ""
  echo "1. ✅ Contract deployed: $CONTRACT"
  echo "2. ⬜ Add liquidity on Uniswap v3 (Base)"
  echo "   https://app.uniswap.org/#/add/ETH/$CONTRACT/3000?chain=base"
  echo ""
  echo "3. ⬜ Register Uniswap pool as AMM pair:"
  echo "   cast send $CONTRACT 'setAmmPair(address,bool)' <POOL_ADDRESS> true \\"
  echo "     --private-key \$PRIVATE_KEY --rpc-url $RPC"
  echo ""
  echo "4. ⬜ Lock liquidity (Unicrypt):"
  echo "   https://app.unicrypt.network/amm/uni-v2/lock"
  echo ""
  echo "5. ⬜ Announce on Twitter + Telegram (content pre-loaded)"
  echo "6. ⬜ Submit to DEX Screener"
  echo "7. ⬜ Submit to DexTools"
  echo "8. ⬜ Update website contract address"
  echo ""
  echo "Red Shell = Green Candle 🦞🚀"
fi
