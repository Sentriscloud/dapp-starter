// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @notice Tiny ERC-20 with EIP-2612 permit so the read-side script can do
///         gasless approvals from the deployer wallet without a separate tx.
/// @dev    Pinned to OpenZeppelin Contracts v5; if you bump OZ, the constructor
///         signature changes (v5 dropped the no-argument default in `ERC20Permit`).
contract SentrixDemoToken is ERC20, ERC20Permit {
    constructor(uint256 initialSupply, address recipient)
        ERC20("Sentrix Demo Token", "DEMO")
        ERC20Permit("Sentrix Demo Token")
    {
        _mint(recipient, initialSupply);
    }
}
