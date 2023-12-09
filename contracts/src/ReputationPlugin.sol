// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IERC20, ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Plugin } from "@1inch/token-plugins/contracts/Plugin.sol";
import { IERC20Plugins } from "@1inch/token-plugins/contracts/interfaces/IERC20Plugins.sol";
import { IReputationPlugin } from "./IReputationPlugin.sol";
import "forge-std/console.sol";

contract ReputationPlugin is IReputationPlugin, Plugin, ERC20 {
    error ApproveDisabled();
    error TransferDisabled();

    mapping(address => mapping(address => uint256)) public vouched;
    uint256 vouchesSent;
    uint256 vouchesReceived;

    constructor(string memory name_, string memory symbol_, IERC20Plugins token_)
        ERC20(name_, symbol_) Plugin(token_)
    {}  // solhint-disable-line no-empty-blocks

    function vouch(address vouchee, uint256 amount) public virtual {
        require(vouchee != msg.sender, "Cannot vouch for yourself!");

        uint256 balance = IERC20Plugins(token).pluginBalanceOf(address(this), msg.sender);
        console.logUint(balance);
        console.logUint(amount);
        if (balance >= amount) {
            _updateBalances(msg.sender, vouchee, amount);
        }

        vouched[msg.sender][vouchee] += amount;
        emit Vouched(msg.sender, vouchee, amount);
    }

    function vouchFrom(address fromVouchee, address toVouchee, uint256 amount) public virtual {
        require(vouched[msg.sender][fromVouchee] >= amount, "Not enough vouching power");
        require(toVouchee != msg.sender, "Cannot vouch for yourself!");
        
        vouched[msg.sender][fromVouchee] -= amount;
        vouched[msg.sender][toVouchee] += amount;
        emit Vouched(msg.sender, toVouchee, amount);
        
        _updateBalances(fromVouchee, toVouchee, amount);
    }

    // function unvouch(address vouchee, uint amount) public virtual {
    //     require(vouched[msg.sender][vouchee] >= amount, "Not enough vouching power");

    //     vouched[msg.sender][vouchee] -= amount;
    //     emit UnVouched(msg.sender, vouchee, amount);
        
    //     _updateBalances(vouchee, msg.sender, amount);
    // }

    function _updateBalances(address from, address to, uint256 amount) internal override {
        _updateBalances(
            from,
            to,
            from == address(0) ? address(0) : from,
            to == address(0) ? address(0) : to,
            amount
        );
    }

    function _updateBalances(address /* from */, address /* to */, address fromDelegatee, address toDelegatee, uint256 amount) internal virtual {
        if (fromDelegatee != toDelegatee && amount > 0) {
            if (fromDelegatee == address(0)) {
                console.log("Minting %d to %s", amount, toDelegatee);
                _mint(toDelegatee, amount);
            } else if (toDelegatee == address(0)) {
                console.log("Burning %d from %s", amount, fromDelegatee);
                _burn(fromDelegatee, amount);
            } else {
                console.log("Transferring %d from %s to %s", amount, fromDelegatee, toDelegatee);
                _transfer(fromDelegatee, toDelegatee, amount);
            }
        }
    }

    // ERC20 overrides

    function transfer(address /* to */, uint256 /* amount */) public pure override(IERC20, ERC20) returns (bool) {
        revert TransferDisabled();
    }

    function transferFrom(address /* from */, address /* to */, uint256 /* amount */) public pure override(IERC20, ERC20) returns (bool) {
        revert TransferDisabled();
    }

    function approve(address /* spender */, uint256 /* amount */) public pure override(ERC20, IERC20) returns (bool) {
        revert ApproveDisabled();
    }

    // function increaseAllowance(address /* spender */, uint256 /* addedValue */) public pure override returns (bool) {
    //     revert ApproveDisabled();
    // }

    // function decreaseAllowance(address /* spender */, uint256 /* subtractedValue */) public pure override returns (bool) {
    //     revert ApproveDisabled();
    // }
}