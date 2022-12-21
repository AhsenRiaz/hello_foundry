// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
// custom remapping
import "solmate-utils/SafeTransferLib.sol";

contract Counter {
    uint256 public number;
    event Number (uint256 num);

    function setNumber(uint256 newNumber) public {
        number = newNumber;
        emit Number (newNumber);
    }

    function increment() public {
        number++;
    }
}
