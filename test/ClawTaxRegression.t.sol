// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CLAWToken.sol";

/// Regression: tax must fire on an ordinary wallet-to-wallet transfer.
///
/// The bug this pins was recorded in CONTRACT_AUDIT_NOTES.md and measured on
/// 2026-11-11 against the committed contract: the old revision charged tax
/// only when from == owner() (a sell) or to == owner() (a buy). An ordinary
/// transfer -- and every DEX swap, since a pool is never the owner -- paid
/// nothing, so the burn and the reward pool were funded only when the owner
/// personally transacted.
///
/// Measured, same input both times (alice sends 1000 CLAW to bob, neither is
/// the owner):
///
///   committed contract : bob received 1000 CLAW, tax collected 0
///   this contract      : bob received  970 CLAW, tax collected 30 CLAW
///                        (20 to the burn address, 10 to the reward pool)
///
/// The old contract's constructor took a marketing-wallet argument and this
/// one does not, so the two revisions cannot be compiled by the same test
/// file. The old-revision probe is kept alongside the archived source at
/// /tmp/claw-old-proof rather than in this tree.
contract ClawTaxRegressionTest is Test {
    address internal rewardPool = address(0xFEED);

    function testOrdinaryTransferIsTaxed() public {
        CLAWToken token = new CLAWToken();
        // The default reward pool is the burn address, which would make the
        // two shares indistinguishable. Point it somewhere else so the split
        // can be checked.
        token.setRewardPool(rewardPool);

        address alice = address(0xA11CE);
        address bob = address(0xB0B);

        // The deployer is tax-exempt, so alice can be funded cleanly.
        token.transfer(alice, 1000 ether);

        vm.prank(alice);
        token.transfer(bob, 1000 ether);

        uint256 bobReceived = token.balanceOf(bob);
        uint256 burned = token.balanceOf(token.DEAD_WALLET());
        uint256 rewarded = token.balanceOf(rewardPool);

        assertGt(bobReceived, 0, "bob should receive tokens");
        assertLt(bobReceived, 1000 ether, "an ordinary transfer must pay tax (the old contract sent the full amount)");
        assertGt(burned, 0, "the burn address must receive its share");
        assertGt(rewarded, 0, "the reward pool must receive its share");

        // 2% of 1000 CLAW burns, 1% rewards. Nothing may be lost in the split.
        assertEq(burned, 20 ether, "2% of the transfer is burned");
        assertEq(rewarded, 10 ether, "1% of the transfer goes to the reward pool");
        assertEq(
            burned + rewarded,
            1000 ether - bobReceived,
            "every token taken in tax must land in the burn address or the reward pool"
        );
    }

    function testTotalTaxIsThreePercent() public {
        CLAWToken token = new CLAWToken();
        assertEq(token.totalTaxBps(), 300, "3% total tax (2% burn + 1% reward)");
        assertEq(token.totalTaxPercent(), 3, "3% expressed as a percent");
    }
}
