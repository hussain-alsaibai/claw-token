#!/bin/bash
# CLAW Token — Deploy to Base Sepolia via Foundry
# Usage: PRIVATE_KEY=0x... bash scripts/deploy-sepolia.sh

set -e

echo "🦞 CLAW Token — Base Sepolia Deploy"
echo "======================================"

# Require private key
if [ -z "$PRIVATE_KEY" ]; then
  echo "❌ Error: Set PRIVATE_KEY environment variable"
  echo "   export PRIVATE_KEY=0x..."
  exit 1
fi

FORGE="/home/node/.foundry/bin/forge"
CAST="/home/node/.foundry/bin/cast"
RPC="https://sepolia.base.org"

# Check wallet balance
DEPLOYER=$($CAST wallet address --private-key $PRIVATE_KEY)
echo "Deployer: $DEPLOYER"

BALANCE=$($CAST balance $DEPLOYER --rpc-url $RPC)
echo "Balance:  $BALANCE ETH"

if [ "$BALANCE" = "0.000000000000000000" ]; then
  echo ""
  echo "⚠️  No ETH on Base Sepolia."
  echo "   Get testnet ETH from: https://faucet.quicknode.com/base/sepolia"
  echo "   Or: https://www.alchemy.com/faucets/base-sepolia"
  exit 1
fi

echo ""
echo "📦 Building contract..."
$FORGE build --quiet

echo "🚀 Deploying CLAWToken..."
DEPLOY_OUTPUT=$($FORGE script script/Deploy.s.sol:DeployScript \
  --rpc-url $RPC \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  2>&1)

echo "$DEPLOY_OUTPUT"

# Extract contract address
CONTRACT=$(echo "$DEPLOY_OUTPUT" | grep "CLAW Token deployed at:" | awk '{print $NF}')

if [ -n "$CONTRACT" ]; then
  echo ""
  echo "✅ Deployment successful!"
  echo "   Contract: $CONTRACT"
  echo "   Network:  Base Sepolia"
  echo "   Explorer: https://sepolia.basescan.org/address/$CONTRACT"
  echo ""

  # Save deployment info
  cat > deployment-sepolia.json << EOF
{
  "contractAddress": "$CONTRACT",
  "deployer": "$DEPLOYER",
  "network": "base-sepolia",
  "chainId": 84532,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "rpc": "$RPC",
  "explorerUrl": "https://sepolia.basescan.org/address/$CONTRACT",
  "tokenomics": {
    "totalSupply": "1000000000",
    "burnBps": 200,
    "rewardBps": 100,
    "totalTaxBps": 300,
    "maxWalletPct": 2
  }
}
EOF
  echo "   Saved: deployment-sepolia.json"

  # Update DEPLOYMENT_GUIDE with new address
  echo ""
  echo "📝 Next steps:"
  echo "   1. Register AMM pair after adding liquidity:"
  echo "      cast send $CONTRACT 'setAmmPair(address,bool)' <POOL_ADDRESS> true \\"
  echo "        --private-key \$PRIVATE_KEY --rpc-url $RPC"
  echo ""
  echo "   2. Verify on BaseScan:"
  echo "      forge verify-contract $CONTRACT CLAWToken \\"
  echo "        --chain-id 84532 --etherscan-api-key \$BASESCAN_API_KEY"
  echo ""
  echo "   3. Update website with new contract address"
  echo "   4. Submit to DEX Screener after mainnet launch"
else
  echo "⚠️  Could not extract contract address. Check output above."
fi
