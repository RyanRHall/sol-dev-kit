// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;

    /// @notice Sets the counter to a specific value.
    /// @param newNumber The new value for the counter.
    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    /// @notice Increments the counter by one.
    function increment() public {
        number++;
    }
}
