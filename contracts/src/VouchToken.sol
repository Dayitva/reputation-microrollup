// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Plugins } from "@1inch/token-plugins/contracts/ERC20Plugins.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract VouchToken is ERC20Plugins, Ownable {
    address public owner;
    constructor(string memory name, string memory symbol, uint256 maxPluginsPerAccount, uint256 pluginCallGasLimit)
        ERC20(name, symbol)
        ERC20Plugins(maxPluginsPerAccount, pluginCallGasLimit)
    {
        owner = msg.sender;
    } // solhint-disable-line no-empty-blocks

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner!");
        _;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}