// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CLAWToken is ERC20, Ownable {
    
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18;
    uint256 public buyTax = 5;
    uint256 public sellTax = 5;
    
    address public marketingWallet;
    address public constant DEAD_WALLET = 0x000000000000000000000000000000000000dEaD;
    
    mapping(address => bool) public isExcludedFromTax;
    
    event TaxDistributed(uint256 holdersAmount, uint256 marketingAmount, uint256 burnAmount);
    
    constructor(address _marketingWallet) ERC20("CLAW Token", "CLAW") Ownable(msg.sender) {
        marketingWallet = _marketingWallet;
        _mint(msg.sender, TOTAL_SUPPLY);
        isExcludedFromTax[msg.sender] = true;
        isExcludedFromTax[address(this)] = true;
    }
    
    function _update(address from, address to, uint256 value) internal virtual override {
        uint256 taxAmount = 0;
        
        if (!isExcludedFromTax[from] && !isExcludedFromTax[to]) {
            if (from == owner()) {
                taxAmount = (value * sellTax) / 100;
            } else if (to == owner()) {
                taxAmount = (value * buyTax) / 100;
            }
        }
        
        if (taxAmount > 0) {
            uint256 holdersAmount = (taxAmount * 40) / 100;
            uint256 marketingAmount = (taxAmount * 40) / 100;
            uint256 burnAmount = (taxAmount * 20) / 100;
            
            super._update(from, marketingWallet, marketingAmount);
            super._update(from, DEAD_WALLET, burnAmount);
            super._update(from, address(this), holdersAmount);
            
            emit TaxDistributed(holdersAmount, marketingAmount, burnAmount);
            
            super._update(from, to, value - taxAmount);
        } else {
            super._update(from, to, value);
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
