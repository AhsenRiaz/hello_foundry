// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "forge-std/Test.sol";
import "../src/Safe.sol";

contract SafeTest is Test {
    Safe safe;

    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    function testWithdraw(uint96 amount) public {
        vm.assume(amount > 0.1 ether);
        payable(address(safe)).transfer(amount);
        uint256 preBalance = address(this).balance;

        safe.withdraw();

        uint256 postBalance = address(this).balance;

        assertEq(preBalance + amount, postBalance);
    }
}
