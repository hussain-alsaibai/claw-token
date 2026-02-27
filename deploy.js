const hre = require("hardhat");

async function main() {
  // Read from environment variables - NO hardcoded secrets
  const PRIVATE_KEY = process.env.PRIVATE_KEY;
  const TENDERLY_RPC = process.env.TENDERLY_RPC;
  
  if (!PRIVATE_KEY) {
    throw new Error("PRIVATE_KEY environment variable not set");
  }
  
  if (!TENDERLY_RPC) {
    throw new Error("TENDERLY_RPC environment variable not set");
  }
  
  console.log("🚀 Deploying CLAW Token...");
  console.log("RPC:", TENDERLY_RPC.replace(/\/\/.*@/, '//****@'));
  
  // Create wallet from private key
  const wallet = new hre.ethers.Wallet(PRIVATE_KEY);
  console.log("Deployer:", wallet.address);
  
  // Connect to provider
  const provider = new hre.ethers.providers.JsonRpcProvider(TENDERLY_RPC);
  const deployer = wallet.connect(provider);
  
  // Check balance
  const balance = await deployer.getBalance();
  console.log("Balance:", hre.ethers.utils.formatEther(balance), "ETH");
  
  // Deploy CLAW Token
  const CLAW = await hre.ethers.getContractFactory("CLAWToken", deployer);
  const claw = await CLAW.deploy(wallet.address);
  
  await claw.deployed();
  
  console.log("✅ CLAW Token deployed!");
  console.log("Contract:", claw.address);
  console.log("Transaction:", claw.deployTransaction.hash);
  
  // Save deployment info
  const deploymentInfo = {
    contractAddress: claw.address,
    deployer: wallet.address,
    transactionHash: claw.deployTransaction.hash,
    timestamp: new Date().toISOString()
  };
  
  require('fs').writeFileSync('deployment.json', JSON.stringify(deploymentInfo, null, 2));
  
  return claw.address;
}

main()
  .then((address) => {
    console.log("\n🎉 Deployment successful!");
    console.log("Contract:", address);
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Deployment failed:", error.message);
    process.exit(1);
  });
