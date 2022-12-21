// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "forge-std/Test.sol";
import "../src/ExpectEmit.sol";


contract EmitContractTest is Test {
    ExpectEmit emitter;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        emitter = new ExpectEmit();
    }

    function testExpectEmit() public {
        // checking topics are the same as expected in the following event
        // 4th arg means we want to also check non-indexed topics too.
        vm.expectEmit(true, true, false, true);
        // the event we expect // will be compared against the emmiteted event from emmiter.t()
        emit Transfer(address(this), address(1337), 1337);
        // the event we get
        emitter.t();
    
    }

    function testExpectEmitDoNotCheckData() public {
        // checking topics are the same as expected in the following event
        vm.expectEmit(true, true, false, false);
        // the event we expect // will be compared against the emmiteted event from emmiter.t()
        emit Transfer(address(this), address(1337), 1338);
        // the event we get
        emitter.t();
    }
}
