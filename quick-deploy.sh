#!/bin/bash
echo "🚀 CLAW Token Quick Deploy Script"
echo "================================="
echo ""
echo "This script will:"
echo "1. Install dependencies"
echo "2. Compile contract"
echo "3. Deploy to Base Goerli"
echo ""
echo "Requirements:"
echo "- Node.js v18+ installed"
echo "- Wallet has testnet ETH"
echo ""
read -p "Press Enter to continue..."

echo ""
echo "📦 Step 1: Installing dependencies..."
npm install

echo ""
echo "🔨 Step 2: Compiling contract..."
npx hardhat compile

echo ""
echo "🚀 Step 3: Deploying to Base Goerli..."
npx hardhat run deploy.js --network baseGoerli

echo ""
echo "✅ Deployment complete!"
echo "Check deployment.json for contract address"
