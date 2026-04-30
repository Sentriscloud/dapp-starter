// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

interface IWSRX {
    function deposit() external payable;
    function balanceOf(address account) external view returns (uint256);
}

contract WrapSrx is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOY_PRIVATE_KEY");
        address deployer = vm.addr(pk);
        // Pull the canonical WSRX address from chain.json values inlined here so
        // the script works without a JSON read library. Mainnet (7119) by
        // default; if RPC_URL points at testnet (7120) use the second one.
        address wsrxMainnet = 0x4693b113e523A196d9579333c4ab8358e2656553;
        address wsrxTestnet = 0x85d5E7694AF31C2Edd0a7e66b7c6c92C59fF949A;
        address wsrx = block.chainid == 7120 ? wsrxTestnet : wsrxMainnet;

        // Wrap 0.01 SRX. Native sends use the standard `payable` deposit
        // pattern; nothing Sentrix-specific.
        uint256 amount = 0.01 ether;

        vm.startBroadcast(pk);
        IWSRX(wsrx).deposit{value: amount}();
        vm.stopBroadcast();

        uint256 wrapped = IWSRX(wsrx).balanceOf(deployer);
        console.log("WSRX address:", wsrx);
        console.log("Wrapped amount this run (wei):", amount);
        console.log("Total WSRX balance for", deployer, ":", wrapped);
    }
}
