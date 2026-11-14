// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CLAWToken
 * @notice AI-powered lobster meme coin on Base. Red Shell = Green Candle. 🦞
 *
 * Tokenomics (on every non-excluded transfer):
 *   - 2% burned permanently (deflationary)
 *   - 1% sent to reward pool (claimable by holder snapshots, or redirected to burn)
 *   - Max wallet: 2% of total supply (anti-whale)
 *
 * Total tax: 3%
 */
contract CLAWToken is ERC20, Ownable {
    // ─── Constants ────────────────────────────────────────────────────────────
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10 ** 18; // 1B CLAW
    address public constant DEAD_WALLET = 0x000000000000000000000000000000000000dEaD;

    // ─── Tax config ───────────────────────────────────────────────────────────
    // Expressed in basis points (100 = 1%)
    uint256 public burnBps = 200; // 2% burn
    uint256 public rewardBps = 100; // 1% reward pool
    // Total tax = burnBps + rewardBps = 300 bps = 3%

    uint256 public constant MAX_TAX_BPS = 1000; // hard cap: 10% total

    // ─── Anti-whale ───────────────────────────────────────────────────────────
    uint256 public maxWalletAmount = TOTAL_SUPPLY * 2 / 100; // 2% of supply
    bool public maxWalletEnabled = true;

    // ─── DEX pairs ────────────────────────────────────────────────────────────
    // Tax fires on transfers involving a registered AMM pair (buy/sell on DEX)
    // AND on all other non-excluded transfers (wallet-to-wallet)
    mapping(address => bool) public isAmmPair;

    // ─── Exclusions ───────────────────────────────────────────────────────────
    mapping(address => bool) public isExcludedFromTax;
    mapping(address => bool) public isExcludedFromMaxWallet;

    // ─── Reward pool ─────────────────────────────────────────────────────────
    address public rewardPool; // Address that accumulates reward tokens
    // Set to DEAD_WALLET initially (extra burn)
    // Can be updated to a staking/distribution contract

    // ─── Events ───────────────────────────────────────────────────────────────
    event TaxDistributed(address indexed from, uint256 burnAmount, uint256 rewardAmount);
    event AmmPairSet(address indexed pair, bool indexed value);
    event RewardPoolUpdated(address indexed oldPool, address indexed newPool);
    event TaxUpdated(uint256 burnBps, uint256 rewardBps);
    event MaxWalletUpdated(uint256 newMax);
    event MaxWalletToggled(bool enabled);

    // ─── Constructor ──────────────────────────────────────────────────────────
    constructor() ERC20("CLAW Token", "CLAW") Ownable(msg.sender) {
        rewardPool = DEAD_WALLET; // Default: reward goes to burn until staking contract ready

        // Exclude deployer and contract from tax + max wallet
        isExcludedFromTax[msg.sender] = true;
        isExcludedFromTax[address(this)] = true;
        isExcludedFromTax[DEAD_WALLET] = true;

        isExcludedFromMaxWallet[msg.sender] = true;
        isExcludedFromMaxWallet[address(this)] = true;
        isExcludedFromMaxWallet[DEAD_WALLET] = true;

        _mint(msg.sender, TOTAL_SUPPLY);
    }

    // ─── Transfer hook ────────────────────────────────────────────────────────
    function _update(address from, address to, uint256 value) internal virtual override {
        // Skip tax for mint/burn and excluded addresses
        if (from == address(0) || to == address(0) || isExcludedFromTax[from] || isExcludedFromTax[to]) {
            super._update(from, to, value);
            _checkMaxWallet(to, value);
            return;
        }

        // Calculate tax
        uint256 combinedTaxBps = burnBps + rewardBps;
        uint256 taxAmount = (value * combinedTaxBps) / 10000;

        if (taxAmount > 0) {
            uint256 burnAmount = (value * burnBps) / 10000;
            uint256 rewardAmount = taxAmount - burnAmount; // remainder to reward pool

            // Send burn portion → dead wallet
            super._update(from, DEAD_WALLET, burnAmount);
            // Send reward portion → reward pool
            if (rewardAmount > 0) {
                super._update(from, rewardPool, rewardAmount);
            }

            emit TaxDistributed(from, burnAmount, rewardAmount);

            // Send net amount to recipient
            super._update(from, to, value - taxAmount);
        } else {
            super._update(from, to, value);
        }

        _checkMaxWallet(to, 0); // balance already updated
    }

    /// @dev Reverts if recipient would exceed maxWalletAmount
    function _checkMaxWallet(
        address to,
        uint256 /*pendingAmount*/
    )
        internal
        view
    {
        if (!maxWalletEnabled) return;
        if (isExcludedFromMaxWallet[to]) return;
        if (isAmmPair[to]) return; // LP pools are exempt
        require(balanceOf(to) <= maxWalletAmount, "CLAW: exceeds max wallet");
    }

    // ─── Owner configuration ─────────────────────────────────────────────────

    /// @notice Register or unregister an AMM pair (Uniswap pool, etc.)
    function setAmmPair(address pair, bool value) external onlyOwner {
        require(pair != address(0), "CLAW: zero address");
        isAmmPair[pair] = value;
        isExcludedFromMaxWallet[pair] = value; // pools are always exempt from max wallet
        emit AmmPairSet(pair, value);
    }

    /// @notice Update tax rates (hard cap: 10% combined)
    function setTax(uint256 _burnBps, uint256 _rewardBps) external onlyOwner {
        require(_burnBps + _rewardBps <= MAX_TAX_BPS, "CLAW: tax exceeds 10%");
        burnBps = _burnBps;
        rewardBps = _rewardBps;
        emit TaxUpdated(_burnBps, _rewardBps);
    }

    /// @notice Update the reward pool address (e.g., deploy a staking contract later)
    function setRewardPool(address _rewardPool) external onlyOwner {
        require(_rewardPool != address(0), "CLAW: zero address");
        emit RewardPoolUpdated(rewardPool, _rewardPool);
        rewardPool = _rewardPool;
    }

    /// @notice Exclude or include an address from tax
    function setExcludedFromTax(address account, bool excluded) external onlyOwner {
        isExcludedFromTax[account] = excluded;
    }

    /// @notice Exclude or include an address from max wallet check
    function setExcludedFromMaxWallet(address account, bool excluded) external onlyOwner {
        isExcludedFromMaxWallet[account] = excluded;
    }

    /// @notice Update max wallet limit (minimum 0.5% of supply)
    function setMaxWalletAmount(uint256 _maxWalletAmount) external onlyOwner {
        require(_maxWalletAmount >= TOTAL_SUPPLY / 200, "CLAW: max wallet too low");
        maxWalletAmount = _maxWalletAmount;
        emit MaxWalletUpdated(_maxWalletAmount);
    }

    /// @notice Toggle max wallet enforcement
    function setMaxWalletEnabled(bool _enabled) external onlyOwner {
        maxWalletEnabled = _enabled;
        emit MaxWalletToggled(_enabled);
    }

    // ─── View helpers ─────────────────────────────────────────────────────────

    /// @notice Returns total tax in basis points
    function totalTaxBps() external view returns (uint256) {
        return burnBps + rewardBps;
    }

    /// @notice Returns tax as percentage string for UI display
    function totalTaxPercent() external view returns (uint256) {
        return (burnBps + rewardBps) / 100;
    }
}
