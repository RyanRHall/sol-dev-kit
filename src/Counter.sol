// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

/// @title Counter
/// @author sol-dev-kit
/// @notice A simple counter contract for demonstration purposes.
contract Counter {
    /// @notice The current counter value.
    uint256 public number;

    /// @notice Sets the counter to a specific value.
    /// @param newNumber The new value for the counter.
    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    /// @notice Increments the counter by one.
    function increment() public {
        ++number;
    }
}
