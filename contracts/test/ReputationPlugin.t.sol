// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ReputationPlugin.sol";
import "../src/VouchToken.sol";
import { IERC20Plugins } from "@1inch/token-plugins/contracts/interfaces/IERC20Plugins.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ReputationPluginTest is Test {
    ReputationPlugin public plugin;
    VouchToken public token;

    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address user3 = vm.addr(3);

    function setUp() public {
        token = new VouchToken("Vouch", "VCH", 1, 100000);
        plugin = new ReputationPlugin("Vouch", "VCH", token);

        // uint256 balance1 = IERC20Plugins(token).pluginBalanceOf(address(this), address(1));
        // uint256 balance2 = IERC20Plugins(token).pluginBalanceOf(address(this), address(2));
        // console.log(balance1);
        // console.log(balance2);

        token.mint(user1, 100);

        vm.startPrank(user1);
        token.addPlugin(address(plugin));
        vm.stopPrank();

        vm.startPrank(user2);
        token.addPlugin(address(plugin));
        vm.stopPrank();

        vm.startPrank(user3);
        token.addPlugin(address(plugin));
        vm.stopPrank();
    }

    function print() public view {
        uint256 tokenBalance1 = IERC20Plugins(token).pluginBalanceOf(address(plugin), user1);
        uint256 tokenBalance2 = IERC20Plugins(token).pluginBalanceOf(address(plugin), user2);
        uint256 tokenBalance3 = IERC20Plugins(token).pluginBalanceOf(address(plugin), user3);

        uint256 pluginBalance1 = ERC20(plugin).balanceOf(user1);
        uint256 pluginBalance2 = ERC20(plugin).balanceOf(user2);
        uint256 pluginBalance3 = ERC20(plugin).balanceOf(user3);

        console.log("Token Balance for %s: %d", user1, tokenBalance1);
        console.log("Plugin Balance for %s: %d", user1, pluginBalance1);

        console.log("Token Balance for %s: %d", user2, tokenBalance2);
        console.log("Plugin Balance for %s: %d", user2, pluginBalance2);

        console.log("Token Balance for %s: %d", user3, tokenBalance3);
        console.log("Plugin Balance for %s: %d", user3, pluginBalance3);
        console.log("====================================");
    }

    function testVouch() public {
        print();
        vm.prank(user1);
        plugin.vouch(user2, 25);
        print();
        vm.prank(user1);
        plugin.vouch(user3, 35);
        print();
        vm.prank(user1);
        plugin.vouchFrom(user2, user3, 15);
        print();
        vm.prank(user3);
        vm.expectRevert("Not enough vouching power!");
        plugin.vouchFrom(user2, user1, 10);
        print();
    }

    // function testVouch2() public {
    //     print();
    //     vm.prank(user1);
    //     plugin.vouch(user3, 35);
    //     print();
    // }
    
}
