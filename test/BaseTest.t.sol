// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

/// @title BaseTest
/// @notice Base test contract for all tests
abstract contract BaseTest is Test {
    /// @notice The nonce for generating pseudo-random values
    uint256 private nonce;

    /// @notice Generates a random bytes32 value using an incrementing nonce
    /// @dev Hashes the nonce value and increments it to ensure different values on each call
    /// @return random bytes32 value
    function randomBytes32() internal returns (bytes32) {
        return keccak256(abi.encodePacked(++nonce));
    }

    /// @notice Generates a random bytes array of a given length
    /// @param length the length of the bytes array to generate
    /// @return random bytes array
    function randomBytes(uint256 length) internal returns (bytes memory) {
        bytes memory result = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = randomBytes32()[0];
        }
        return result;
    }
}
