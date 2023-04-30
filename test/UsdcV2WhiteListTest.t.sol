// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {UsdcV2} from "../src/UsdcV2.sol";

contract UsdcV2WhiteListTest is Test {
    // Users
    address user1;
    address user2;

    address USDC_PROXY_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address USDC_ADMIN = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;

    // Contracts
    UsdcV2 proxyUsdcV2;
    UsdcV2 usdcV2;

    function upgrade() public {
        vm.startPrank(USDC_ADMIN);
        usdcV2 = new UsdcV2("UsdcV2", "UV2", 18);
        (bool success, ) = address(USDC_PROXY_ADDRESS).call(abi.encodeWithSignature("upgradeTo(address)", address(usdcV2)));
        assertEq(success, true);
        proxyUsdcV2 = UsdcV2(USDC_PROXY_ADDRESS);
        vm.stopPrank();
    }

    function setUp() public {
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function testAddUserToWhitelist() public {
        upgrade();
        vm.startPrank(USDC_ADMIN);
        assertFalse(proxyUsdcV2.isUserInWhitelist(user1));
        proxyUsdcV2.addUserToWhitelist(user1);
        assertTrue(usdcV2.isUserInWhitelist(address(user1)));
        vm.stopPrank();
    }

    function testRemoveUserFromWhitelist() public {
        upgrade();
        vm.startPrank(USDC_ADMIN);
        proxyUsdcV2.addUserToWhitelist(address(user1));
        assertTrue(proxyUsdcV2.isUserInWhitelist(user1));
        proxyUsdcV2.removeUserFromWhitelist(address(user1));
        assertFalse(proxyUsdcV2.isUserInWhitelist(user1));
        vm.stopPrank();
    }

    function testUserNotInWhitelist() public {
        upgrade();
        vm.startPrank(user1);
        vm.expectRevert("This address don't have the authority to mint");
        proxyUsdcV2.transfer(address(user2), 1);
        vm.stopPrank();
    }

    function testUserMintFromWhitelist() public {
        upgrade();
        vm.startPrank(USDC_ADMIN);
        proxyUsdcV2.addUserToWhitelist(address(user2));
        assertTrue(proxyUsdcV2.isUserInWhitelist(user2));
        proxyUsdcV2.mint(address(user2), 100);
        assertEq(proxyUsdcV2.balanceOf(user2), 100);
        vm.stopPrank();
    }

}