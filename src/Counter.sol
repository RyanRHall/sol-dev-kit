// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

/// @title Counter
/// @author sol-dev-kit
/// @notice A simple counter contract for demonstration purposes.
contract Counter {
    /// @notice Emitted when the counter is reset.
    event Reset(uint256 previousValue);

    /// @notice Thrown when trying to decrement below zero.
    error Underflow();

    /// @notice The current counter value.
    uint256 public number;

    /// @notice Sets the counter to a specific value.
    /// @param newNumber The new value for the counter.
    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    /// @notice Increments the counter by one.
    function increment() public {
        ++number;
    }

    /// @notice Decrements the counter by one.
    function decrement() public {
        if (number <= 0) revert Underflow();
        number -= 1;
    }

    /// @notice Adds a value to the counter.
    /// @param value The amount to add.
    function add(uint256 value) public {
        number += value;
    }

    /// @notice Multiplies the counter by a factor.
    /// @param factor The multiplier.
    function multiply(uint256 factor) public {
        number = number * factor;
    }

    /// @notice Resets the counter to zero.
    function reset() public {
        uint256 prev = number;
        number = 0;
        if (prev > 0) {
            emit Reset(prev);
        }
    }

    /// @notice Returns whether the counter exceeds a threshold.
    /// @param threshold The value to compare against.
    /// @return exceeded True if the counter is strictly greater than the threshold.
    function exceeds(uint256 threshold) public view returns (bool exceeded) {
        exceeded = number > threshold;
    }
}
