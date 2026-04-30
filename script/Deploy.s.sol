// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {SentrixDemoToken} from "../contracts/SentrixDemoToken.sol";

contract Deploy is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOY_PRIVATE_KEY");
        address deployer = vm.addr(pk);
        // 1,000,000 tokens at 18 decimals.
        uint256 supply = 1_000_000 ether;

        vm.startBroadcast(pk);
        SentrixDemoToken token = new SentrixDemoToken(supply, deployer);
        vm.stopBroadcast();

        console.log("Sentrix Demo Token deployed at:", address(token));
        console.log("Initial supply minted to:", deployer);
    }
}
