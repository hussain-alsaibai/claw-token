#!/usr/bin/env python3
"""
CLAW Token Deployment - UPDATED for web3 v7.x
"""

import json
import os
from web3 import Web3

# Configuration
PRIVATE_KEY = "0x0c4ad5af11eee32f5389fd35a64e64c2bad466191fc6543ba8e0efd5941ab5a4"
ADDRESS = "0x72389856bffde3c25b99be2f053145b0761bfdec"

# Base Sepolia (Current Testnet)
RPC_URL = "https://sepolia.base.org"
CHAIN_ID = 84532

# Simplified contract for deployment testing
# Using minimal bytecode to save gas
CONTRACT_BYTECODE = "0x" + "608060405234801561001057600080fd5b50" + "6103e860008190555061016380610027" + "6000396000f3fe6080604052600436" + "1061004c5760003560e01c806306fd" + "de031461005157806395d89b41146" + "1006b57806318160ddd1461008557" + "8063a9059cbb14610090575b60008" + "0fd5b6100596100c1565b60405161" + "006691906100f8565b6040518091" + "0390f35b6100736100d0565b60405" + "161008091906100f8565b60405180" + "910390f35b61008b6100df565b00" + "5b6100bb60048036038101906100b" + "69190610144565b6100e8565b6040" + "516100c891906100f8565b6040518" + "0910390f35b60006001905090565b" + "60006003905090565b60006001549" + "05090565b60006100f3838361011a" + "565b905092915050565b600081905" + "0919050565b610111816100fc565b" + "82525050565b60006020820190506" + "1012b6000830184610108565b92915" + "050565b600080fd5b600081151590" + "50919050565b61014e81610139565b" + "81141561015d57600080fd5b50565" + "b61016a81610134565b8114610175" + "57600080fd5b5056fea2646970667" + "358221220e0e1a8a7c6b5d4e3f2a1" + "b9c8d7e6f504938271665544332211" + "0064736f6c63430008190033"

CONTRACT_ABI = [
    {"inputs": [], "name": "name", "outputs": [{"internalType": "string", "name": "", "type": "string"}], "stateMutability": "view", "type": "function"},
    {"inputs": [], "name": "symbol", "outputs": [{"internalType": "string", "name": "", "type": "string"}], "stateMutability": "view", "type": "function"},
    {"inputs": [], "name": "totalSupply", "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}], "stateMutability": "view", "type": "function"},
]

def main():
    print("🚀 CLAW Token Deployment (Python + web3)")
    print("=" * 50)
    
    # Connect to Base Goerli
    print(f"\n📡 Connecting to Base Goerli...")
    w3 = Web3(Web3.HTTPProvider(RPC_URL))
    
    if not w3.is_connected():
        print("❌ Failed to connect")
        return
    
    print(f"✅ Connected! Block: {w3.eth.block_number}")
    
    # Check balance (use checksummed address)
    checksum_address = Web3.to_checksum_address(ADDRESS)
    balance = w3.eth.get_balance(checksum_address)
    balance_eth = w3.from_wei(balance, 'ether')
    print(f"\n💰 Wallet: {ADDRESS}")
    print(f"💰 Balance: {balance_eth} ETH")
    
    if balance_eth < 0.001:
        print("\n❌ INSUFFICIENT FUNDS!")
        print("   Need: 0.01 ETH for gas")
        print("   Get free ETH from:")
        print("   https://www.alchemy.com/faucets/base-sepolia")
        return
    
    print("\n✅ Balance sufficient!")
    print("\n🚀 Ready to deploy CLAW Token")
    print("   This will deploy a minimal ERC-20 token")
    print("   for testing purposes.")
    
    return True  # Ready to deploy

if __name__ == "__main__":
    result = main()
    if result:
        print("\n✅ READY FOR DEPLOYMENT")
        print("   Run full deploy script when funded")
    else:
        print("\n❌ DEPLOYMENT BLOCKED")
        print("   Fund wallet with testnet ETH first")
