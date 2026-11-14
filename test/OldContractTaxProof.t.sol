// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

/// The OLD revision's tax logic, reproduced verbatim so the evidence survives
/// in the repository instead of living in a scratch directory.
///
/// It cannot be compiled alongside the current revision, because the two have
/// different constructor arity, so it is kept as a separate contract here.
/// Only the ERC20 balance bookkeeping is stood in for; the tax logic -- the
/// part that was wrong -- is copied exactly from the committed pre-fix
/// revision.
contract OldCLAWToken {
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10 ** 18;
    uint256 public buyTax = 5;
    uint256 public sellTax = 5;

    address public marketingWallet;
    address public constant DEAD_WALLET = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) public isExcludedFromTax;

    event TaxDistributed(uint256 holdersAmount, uint256 marketingAmount, uint256 burnAmount);

    mapping(address => uint256) internal _balances;
    address internal _owner;

    constructor(address _marketingWallet) {
        _owner = msg.sender;
        marketingWallet = _marketingWallet;
        _mint(msg.sender, TOTAL_SUPPLY);
        isExcludedFromTax[msg.sender] = true;
        isExcludedFromTax[address(this)] = true;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function _mint(address to, uint256 amount) internal {
        _balances[to] += amount;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _update(msg.sender, to, value);
        return true;
    }

    /// Verbatim from the committed pre-fix revision.
    function _update(address from, address to, uint256 value) internal virtual {
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

            _mint(marketingWallet, marketingAmount);
            _mint(DEAD_WALLET, burnAmount);
            _mint(address(this), holdersAmount);

            emit TaxDistributed(holdersAmount, marketingAmount, burnAmount);

            _balances[from] -= value - taxAmount;
            _balances[to] += value - taxAmount;
        } else {
            _balances[from] -= value;
            _balances[to] += value;
        }
    }
}

/// Proof of the bug that the 2026-11-11 rewrite fixed.
///
/// The old contract charged tax only when from == owner() (a sell) or
/// to == owner() (a buy). An ordinary wallet-to-wallet transfer paid nothing,
/// and neither did a DEX swap, because a pool is never the owner.
///
/// It is worse than that. The constructor puts the deployer in
/// isExcludedFromTax, so the owner -- the only address the tax branches could
/// ever match -- was always excluded. The from == owner() and to == owner()
/// branches were dead code, and the old contract could not collect a single
/// token of tax under any circumstances.
///
/// Measured on 2026-11-11 with the same input against both revisions --
/// alice sends 1000 CLAW to bob, neither is the owner:
///
///   old revision : bob received 1000 CLAW, tax collected 0
///   new revision : bob received  970 CLAW, tax collected 30 CLAW
contract OldContractTaxProofTest is Test {
    /// The bug: an ordinary transfer is untaxed.
    function testOldContractChargesNoTaxOnOrdinaryTransfer() public {
        OldCLAWToken token = new OldCLAWToken(address(0xBEEF));

        address alice = address(0xA11CE);
        address bob = address(0xB0B);

        token.transfer(alice, 1000 ether);

        vm.prank(alice);
        token.transfer(bob, 1000 ether);

        assertEq(token.balanceOf(bob), 1000 ether, "CONFIRMED: the old contract paid NO tax on an ordinary transfer");
        assertEq(
            token.balanceOf(token.marketingWallet()),
            0,
            "CONFIRMED: the marketing wallet received nothing from that transfer"
        );
        assertEq(token.balanceOf(token.DEAD_WALLET()), 0, "CONFIRMED: nothing was burned by that transfer");
    }

    /// Worse: the owner's own transfers were untaxed too, because the
    /// constructor excludes the deployer. That made the from == owner() and
    /// to == owner() branches dead code, so the contract could not collect
    /// tax under ANY circumstances.
    function testOldContractNeverCollectedAnyTaxAtAll() public {
        OldCLAWToken token = new OldCLAWToken(address(0xBEEF));

        address bob = address(0xB0B);

        // The owner's own transfer: the sell path that was supposed to work.
        token.transfer(bob, 1000 ether);

        assertEq(
            token.balanceOf(bob),
            1000 ether,
            "CONFIRMED: even the owner's own transfer was untaxed -- the owner is tax-exempt"
        );
        assertEq(token.balanceOf(token.marketingWallet()), 0, "CONFIRMED: the marketing wallet never received anything");
        assertEq(token.balanceOf(token.DEAD_WALLET()), 0, "CONFIRMED: nothing was ever burned");
        assertEq(token.balanceOf(address(token)), 0, "CONFIRMED: the holders' share never accrued");
    }
}
