const hre = require("hardhat");
const { ethers } = require("ethers");

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

  // ethers v6 API
  const provider = new ethers.JsonRpcProvider(TENDERLY_RPC);
  const deployer = new ethers.Wallet(PRIVATE_KEY, provider);
  console.log("Deployer:", deployer.address);

  // Check balance
  const balance = await provider.getBalance(deployer.address);
  console.log("Balance:", ethers.formatEther(balance), "ETH");

  // Deploy CLAW Token using hardhat's contract factory (uses hre signer)
  const CLAW = await hre.ethers.getContractFactory("CLAWToken");
  // The 2026-11-11 revision of CLAWToken has a zero-argument constructor:
  // the marketing wallet was removed and the reward pool defaults to the
  // burn address until a staking contract exists. Passing an address here
  // is an argument-count error, and this script runs on every push to main
  // via deploy.yml.
  const claw = await CLAW.connect(deployer).deploy();

  await claw.waitForDeployment();

  const contractAddress = await claw.getAddress();
  const deployTx = claw.deploymentTransaction();

  console.log("✅ CLAW Token deployed!");
  console.log("Contract:", contractAddress);
  console.log("Transaction:", deployTx.hash);

  // Save deployment info
  const deploymentInfo = {
    contractAddress,
    deployer: deployer.address,
    transactionHash: deployTx.hash,
    timestamp: new Date().toISOString(),
    network: "tenderly-base-sepolia"
  };

  require('fs').writeFileSync('deployment.json', JSON.stringify(deploymentInfo, null, 2));

  return contractAddress;
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
