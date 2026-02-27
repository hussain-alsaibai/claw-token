// CLAW Token Deployment Script
// Network: Base Goerli (Testnet)

const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying CLAW Token to Base Goerli...");
  
  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);
  
  // Check balance
  const balance = await deployer.getBalance();
  console.log("Account balance:", hre.ethers.utils.formatEther(balance), "ETH");
  
  if (balance.lt(hre.ethers.utils.parseEther("0.01"))) {
    console.error("❌ Insufficient funds. Get testnet ETH from:");
    console.error("   https://www.alchemy.com/faucets/base-sepolia");
    console.error("   https://faucet.quicknode.com/base/goerli");
    process.exit(1);
  }
  
  // Deploy CLAW Token
  const CLAWToken = await hre.ethers.getContractFactory("CLAWToken");
  
  // Marketing wallet = deployer for testnet
  const marketingWallet = deployer.address;
  
  console.log("Deploying CLAWToken...");
  const claw = await CLAWToken.deploy(marketingWallet);
  
  await claw.deployed();
  
  console.log("✅ CLAW Token deployed to:", claw.address);
  console.log("📊 View on BaseScan:", `https://goerli.basescan.org/address/${claw.address}`);
  
  // Verify contract
  console.log("⏳ Waiting for block confirmations...");
  await claw.deployTransaction.wait(5);
  
  console.log("📝 To verify contract, run:");
  console.log(`npx hardhat verify --network baseGoerli ${claw.address} ${marketingWallet}`);
  
  // Save deployment info
  const deploymentInfo = {
    network: "Base Goerli",
    contractAddress: claw.address,
    deployer: deployer.address,
    marketingWallet: marketingWallet,
    timestamp: new Date().toISOString(),
    transactionHash: claw.deployTransaction.hash
  };
  
  const fs = require('fs');
  fs.writeFileSync('deployment.json', JSON.stringify(deploymentInfo, null, 2));
  console.log("💾 Deployment info saved to deployment.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
