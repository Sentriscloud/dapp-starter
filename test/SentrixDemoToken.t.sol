// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {SentrixDemoToken} from "../contracts/SentrixDemoToken.sol";

contract SentrixDemoTokenTest is Test {
    SentrixDemoToken token;
    address constant ALICE = address(0xA11CE);
    address constant BOB = address(0xB0B);

    function setUp() public {
        token = new SentrixDemoToken(1_000_000 ether, ALICE);
    }

    function test_initial_supply_minted_to_recipient() public view {
        assertEq(token.totalSupply(), 1_000_000 ether);
        assertEq(token.balanceOf(ALICE), 1_000_000 ether);
    }

    function test_transfer_moves_balance() public {
        vm.prank(ALICE);
        token.transfer(BOB, 100 ether);
        assertEq(token.balanceOf(BOB), 100 ether);
        assertEq(token.balanceOf(ALICE), 999_900 ether);
    }

    function test_metadata() public view {
        assertEq(token.name(), "Sentrix Demo Token");
        assertEq(token.symbol(), "DEMO");
        assertEq(token.decimals(), 18);
    }
}
