// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CLAWToken.sol";

contract CLAWTokenTest is Test {
    CLAWToken public token;
    address public owner;
    address public alice;
    address public bob;
    address public ammPair;

    uint256 constant TOTAL = 1_000_000_000 * 10 ** 18;
    uint256 constant BPS = 10000;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        ammPair = makeAddr("ammPair");

        token = new CLAWToken();

        // Register fake AMM pair
        token.setAmmPair(ammPair, true);

        // Give alice some tokens from owner (owner excluded from tax)
        token.transfer(alice, 10_000_000 * 10 ** 18); // 10M tokens
    }

    // ─── Basic ───────────────────────────────────────────────────────────────

    function test_name() public view {
        assertEq(token.name(), "CLAW Token");
    }

    function test_symbol() public view {
        assertEq(token.symbol(), "CLAW");
    }

    function test_totalSupply() public view {
        assertEq(token.totalSupply(), TOTAL);
    }

    function test_ownerHasTokens() public view {
        // Owner sent 10M to alice, should have TOTAL - 10M
        assertEq(token.balanceOf(owner), TOTAL - 10_000_000 * 10 ** 18);
    }

    // ─── Tax mechanics ────────────────────────────────────────────────────────

    function test_taxFiredOnNonExcludedTransfer() public {
        uint256 sendAmount = 1_000_000 * 10 ** 18; // 1M tokens
        uint256 _burnBps = token.burnBps();
        uint256 _rewardBps = token.rewardBps();

        uint256 expectedBurn = (sendAmount * _burnBps) / BPS;
        uint256 expectedReward = (sendAmount * _rewardBps) / BPS;
        uint256 expectedNet = sendAmount - expectedBurn - expectedReward;

        address deadWallet = token.DEAD_WALLET();
        address rewardPool = token.rewardPool();

        uint256 deadBefore = token.balanceOf(deadWallet);

        vm.prank(alice);
        token.transfer(bob, sendAmount);

        // Bob received net amount (after 3% tax)
        assertEq(token.balanceOf(bob), expectedNet);

        // Total tokens removed from circulation (burn + reward when rewardPool == deadWallet)
        if (rewardPool == deadWallet) {
            // Both burn and reward go to dead wallet
            assertEq(token.balanceOf(deadWallet) - deadBefore, expectedBurn + expectedReward);
        } else {
            assertEq(token.balanceOf(deadWallet) - deadBefore, expectedBurn);
            assertEq(token.balanceOf(rewardPool), expectedReward);
        }
    }

    function test_noTaxForExcludedSender() public {
        uint256 sendAmount = 1_000_000 * 10 ** 18;
        // Owner is excluded from tax
        uint256 bobBefore = token.balanceOf(bob);
        token.transfer(bob, sendAmount);
        assertEq(token.balanceOf(bob) - bobBefore, sendAmount); // no tax
    }

    function test_taxRate3Percent() public view {
        assertEq(token.totalTaxBps(), 300); // 3%
    }

    // ─── Max wallet ────────────────────────────────────────────────────────────

    function test_maxWalletEnforced() public {
        uint256 maxWallet = token.maxWalletAmount(); // 20M tokens (2% of 1B)

        // Give bob just under the max wallet limit (owner transfer = no tax)
        uint256 fillAmount = maxWallet - 1 * 10 ** 18; // 1 token under max
        token.transfer(bob, fillAmount);
        assertLe(token.balanceOf(bob), maxWallet);

        // Now send alice enough to push bob over — even 1 token net should fail
        // After 3% tax, alice needs to send > ~1.03 tokens to net 1 token to bob
        uint256 smallSend = 2 * 10 ** 18; // 2 tokens — net ~1.94 tokens after tax
        // Alice needs tokens; give her some (owner, no tax)
        token.transfer(alice, 10 * 10 ** 18);

        vm.prank(alice);
        vm.expectRevert("CLAW: exceeds max wallet");
        token.transfer(bob, smallSend);
    }

    function test_ammPairExemptFromMaxWallet() public {
        // AMM pair should be able to receive any amount
        uint256 bigAmount = token.maxWalletAmount() * 10; // 10x the limit
        token.transfer(ammPair, bigAmount); // owner sends, no revert
        assertGt(token.balanceOf(ammPair), 0);
    }

    // ─── Owner functions ─────────────────────────────────────────────────────

    function test_setTax() public {
        token.setTax(150, 50); // 1.5% burn + 0.5% reward = 2% total
        assertEq(token.burnBps(), 150);
        assertEq(token.rewardBps(), 50);
        assertEq(token.totalTaxBps(), 200);
    }

    function test_setTaxExceedsMax() public {
        vm.expectRevert("CLAW: tax exceeds 10%");
        token.setTax(600, 500); // 11% — should revert
    }

    function test_setRewardPool() public {
        address newPool = makeAddr("stakingContract");
        token.setRewardPool(newPool);
        assertEq(token.rewardPool(), newPool);
    }

    function test_setMaxWalletAmount() public {
        uint256 newMax = TOTAL * 5 / 100; // 5%
        token.setMaxWalletAmount(newMax);
        assertEq(token.maxWalletAmount(), newMax);
    }

    function test_setMaxWalletTooLow() public {
        vm.expectRevert("CLAW: max wallet too low");
        token.setMaxWalletAmount(TOTAL / 1000); // 0.1% — below 0.5% minimum
    }

    function test_onlyOwnerCanSetTax() public {
        vm.prank(alice);
        vm.expectRevert();
        token.setTax(100, 100);
    }
}
