// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/CLAWToken.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // No constructor args — deployer receives all tokens automatically
        CLAWToken token = new CLAWToken();

        vm.stopBroadcast();

        console.log("CLAW Token deployed at:", address(token));
        console.log("Total supply:          1,000,000,000 CLAW");
        console.log("Burn tax:              2%");
        console.log("Reward tax:            1%");
        console.log("Max wallet:            2% of supply");
        console.log("Reward pool:           DEAD_WALLET (burn) until staking contract set");
    }
}
