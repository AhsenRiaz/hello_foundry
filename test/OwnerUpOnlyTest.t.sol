// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/OwnerUpOnly.sol";

contract OwnerUpOnlyTest is Test {
    OwnerUpOnly uponly;

    function setUp() public {
        uponly = new OwnerUpOnly();
    }

    function testIncrementAsOwner() public {
        assertEq(uponly.count(), 0);
        uponly.increment();
        assertEq(uponly.count(), 1);
    }

    function testIncrementAsNotOwner() public {
        //will create an address and call the function
        vm.expectRevert(Unauthorized.selector);
        vm.prank(address(0));
        uponly.increment();
    }
}
