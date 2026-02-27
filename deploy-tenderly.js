const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying CLAW Token to Tenderly Virtual TestNet...");
  
  // Get wallet from private key
  const wallet = new hre.ethers.Wallet(
    "0x0c4ad5af11eee32f5389fd35a64e64c2bad466191fc6543ba8e0efd5941ab5a4",
    hre.ethers.provider
  );
  
  console.log("Deployer:", wallet.address);
  
  // Check balance
  const balance = await wallet.getBalance();
  console.log("Balance:", hre.ethers.utils.formatEther(balance), "ETH");
  
  // Deploy CLAW Token
  const CLAW = await hre.ethers.getContractFactory("CLAWToken", wallet);
  const claw = await CLAW.deploy(wallet.address);
  
  await claw.deployed();
  
  console.log("✅ CLAW Token deployed!");
  console.log("Contract:", claw.address);
  console.log("Explorer: https://dashboard.tenderly.co/Alsaibai/project/project/vnet/claw-token-vnet/contracts/" + claw.address);
  
  return claw.address;
}

main()
  .then((address) => {
    console.log("\n🎉 CLAW Token is LIVE!");
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
