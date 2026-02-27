// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CLAWToken is ERC20, Ownable {
    
    // Tokenomics
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18; // 1 Billion
    
    // Tax structure: 5% total
    uint256 public buyTax = 5;  // 5% on buys
    uint256 public sellTax = 5; // 5% on sells
    
    // Tax distribution
    uint256 public holdersShare = 40;     // 2% to holders
    uint256 public marketingShare = 40;   // 2% to marketing
    uint256 public burnShare = 20;        // 1% burned
    
    // Wallets
    address public marketingWallet;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    
    // Mappings
    mapping(address => bool) public isExcludedFromTax;
    mapping(address => uint256) public holderRewards;
    
    // Events
    event TaxDistributed(uint256 holdersAmount, uint256 marketingAmount, uint256 burnAmount);
    event TokensBurned(uint256 amount);
    
    constructor(address _marketingWallet) ERC20("CLAW Token", "CLAW") {
        marketingWallet = _marketingWallet;
        
        // Mint total supply to owner
        _mint(msg.sender, TOTAL_SUPPLY);
        
        // Exclude owner and contract from tax
        isExcludedFromTax[msg.sender] = true;
        isExcludedFromTax[address(this)] = true;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        
        uint256 taxAmount = 0;
        
        // Apply tax if not excluded
        if (!isExcludedFromTax[sender] && !isExcludedFromTax[recipient]) {
            if (sender == owner()) {
                // Selling: apply sell tax
                taxAmount = (amount * sellTax) / 100;
            } else if (recipient == owner()) {
                // Buying: apply buy tax
                taxAmount = (amount * buyTax) / 100;
            }
        }
        
        if (taxAmount > 0) {
            // Calculate distribution
            uint256 holdersAmount = (taxAmount * holdersShare) / 100;
            uint256 marketingAmount = (taxAmount * marketingShare) / 100;
            uint256 burnAmount = (taxAmount * burnShare) / 100;
            
            // Distribute taxes
            super._transfer(sender, marketingWallet, marketingAmount);
            super._transfer(sender, deadWallet, burnAmount);
            
            // Holders rewards (accumulated in contract)
            super._transfer(sender, address(this), holdersAmount);
            
            emit TaxDistributed(holdersAmount, marketingAmount, burnAmount);
            
            // Transfer remaining amount
            uint256 remainingAmount = amount - taxAmount;
            super._transfer(sender, recipient, remainingAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }
    }
    
    // Owner functions
    function setTax(uint256 _buyTax, uint256 _sellTax) external onlyOwner {
        require(_buyTax <= 10 && _sellTax <= 10, "Tax cannot exceed 10%");
        buyTax = _buyTax;
        sellTax = _sellTax;
    }
    
    function setMarketingWallet(address _wallet) external onlyOwner {
        marketingWallet = _wallet;
    }
    
    function excludeFromTax(address account, bool excluded) external onlyOwner {
        isExcludedFromTax[account] = excluded;
    }
    
    // Distribute holder rewards
    function distributeRewards(address[] calldata holders) external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance > 0, "No rewards to distribute");
        
        uint256 rewardPerHolder = contractBalance / holders.length;
        
        for (uint i = 0; i < holders.length; i++) {
            _transfer(address(this), holders[i], rewardPerHolder);
        }
    }
    
    // Burn function
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        emit TokensBurned(amount);
    }
}
