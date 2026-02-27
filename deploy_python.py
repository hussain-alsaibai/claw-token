#!/usr/bin/env python3
"""
CLAW Token Deployment Script (Python + web3.py)
No Node.js required!
"""

import json
import os
from web3 import Web3
from solcx import compile_standard, install_solc

# Configuration
PRIVATE_KEY = os.getenv('PRIVATE_KEY', '0x0c4ad5af11eee32f5389fd35a64e64c2bad466191fc6543ba8e0efd5941ab5a4')
ALCHEMY_API_KEY = os.getenv('ALCHEMY_API_KEY', '')

# Base Goerli (Testnet) Configuration
BASE_GOERLI_RPC = f"https://base-goerli.g.alchemy.com/v2/{ALCHEMY_API_KEY}" if ALCHEMY_API_KEY else "https://goerli.base.org"
CHAIN_ID = 84531

# Contract Source
CONTRACT_SOURCE = '''
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CLAWToken is ERC20, Ownable {
    
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18;
    uint256 public buyTax = 5;
    uint256 public sellTax = 5;
    
    uint256 public holdersShare = 40;
    uint256 public marketingShare = 40;
    uint256 public burnShare = 20;
    
    address public marketingWallet;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    
    mapping(address => bool) public isExcludedFromTax;
    
    event TaxDistributed(uint256 holdersAmount, uint256 marketingAmount, uint256 burnAmount);
    
    constructor(address _marketingWallet) ERC20("CLAW Token", "CLAW") {
        marketingWallet = _marketingWallet;
        _mint(msg.sender, TOTAL_SUPPLY);
        isExcludedFromTax[msg.sender] = true;
        isExcludedFromTax[address(this)] = true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        uint256 taxAmount = 0;
        
        if (!isExcludedFromTax[sender] && !isExcludedFromTax[recipient]) {
            if (sender == owner()) {
                taxAmount = (amount * sellTax) / 100;
            } else if (recipient == owner()) {
                taxAmount = (amount * buyTax) / 100;
            }
        }
        
        if (taxAmount > 0) {
            uint256 holdersAmount = (taxAmount * holdersShare) / 100;
            uint256 marketingAmount = (taxAmount * marketingShare) / 100;
            uint256 burnAmount = (taxAmount * burnShare) / 100;
            
            super._transfer(sender, marketingWallet, marketingAmount);
            super._transfer(sender, deadWallet, burnAmount);
            super._transfer(sender, address(this), holdersAmount);
            
            emit TaxDistributed(holdersAmount, marketingAmount, burnAmount);
            
            uint256 remainingAmount = amount - taxAmount;
            super._transfer(sender, recipient, remainingAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }
    }
    
    function setTax(uint256 _buyTax, uint256 _sellTax) external onlyOwner {
        require(_buyTax <= 10 && _sellTax <= 10, "Tax cannot exceed 10%");
        buyTax = _buyTax;
        sellTax = _sellTax;
    }
    
    function excludeFromTax(address account, bool excluded) external onlyOwner {
        isExcludedFromTax[account] = excluded;
    }
}
'''

def deploy_contract():
    print("🚀 CLAW Token Python Deployment")
    print("=" * 40)
    
    # Connect to Base Goerli
    print(f"\n📡 Connecting to Base Goerli...")
    w3 = Web3(Web3.HTTPProvider(BASE_GOERLI_RPC))
    
    if not w3.is_connected():
        print("❌ Failed to connect to Base Goerli")
        print(f"   RPC: {BASE_GOERLI_RPC}")
        return
    
    print(f"✅ Connected! Block number: {w3.eth.block_number}")
    
    # Setup account
    account = w3.eth.account.from_key(PRIVATE_KEY)
    print(f"\n🔑 Deployer: {account.address}")
    
    # Check balance
    balance = w3.eth.get_balance(account.address)
    balance_eth = w3.from_wei(balance, 'ether')
    print(f"💰 Balance: {balance_eth} ETH")
    
    if balance_eth < 0.01:
        print("\n❌ Insufficient funds!")
        print("   Get free testnet ETH from:")
        print("   https://www.alchemy.com/faucets/base-sepolia")
        return
    
    # Compile contract
    print("\n🔨 Compiling contract...")
    install_solc('0.8.19')
    
    compiled_sol = compile_standard({
        "language": "Solidity",
        "sources": {
            "CLAWToken.sol": {
                "content": CONTRACT_SOURCE
            }
        },
        "settings": {
            "outputSelection": {
                "*": {
                    "*": ["abi", "metadata", "evm.bytecode", "evm.bytecode.sourceMap"]
                }
            }
        }
    }, solc_version='0.8.19')
    
    # Extract bytecode and ABI
    contract_data = compiled_sol['contracts']['CLAWToken.sol']['CLAWToken']
    bytecode = contract_data['evm']['bytecode']['object']
    abi = contract_data['abi']
    
    print("✅ Compiled successfully!")
    
    # Deploy
    print("\n🚀 Deploying CLAW Token...")
    CLAW = w3.eth.contract(abi=abi, bytecode=bytecode)
    
    # Build transaction
    nonce = w3.eth.get_transaction_count(account.address)
    construct_txn = CLAW.constructor(account.address).build_transaction({
        'from': account.address,
        'nonce': nonce,
        'gas': 2000000,
        'gasPrice': w3.to_wei('5', 'gwei'),
        'chainId': CHAIN_ID
    })
    
    # Sign and send
    signed = w3.eth.account.sign_transaction(construct_txn, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)
    
    print(f"⏳ Transaction: {tx_hash.hex()}")
    print("   Waiting for confirmation...")
    
    # Wait for receipt
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    contract_address = tx_receipt.contractAddress
    
    print(f"\n✅ CLAW Token deployed!")
    print(f"📍 Contract: {contract_address}")
    print(f"🔍 Explorer: https://goerli.basescan.org/address/{contract_address}")
    
    # Save deployment info
    deployment_info = {
        'network': 'Base Goerli',
        'contract_address': contract_address,
        'deployer': account.address,
        'transaction_hash': tx_hash.hex(),
        'abi': abi
    }
    
    with open('deployment_python.json', 'w') as f:
        json.dump(deployment_info, f, indent=2)
    
    print(f"\n💾 Saved to deployment_python.json")
    print("\n🎉 Deployment complete!")

if __name__ == '__main__':
    deploy_contract()
