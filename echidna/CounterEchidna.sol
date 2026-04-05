// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {Counter} from "../../src/Counter.sol";

/// @notice Echidna property-based test harness for Counter.
contract CounterEchidna is Counter {
    /// @notice A number can never exceed itself.
    function echidna_exceeds_self_is_false() public view returns (bool) {
        return !exceeds(number);
    }

    /// @notice No value can exceed uint256 max.
    function echidna_exceeds_max_is_false() public view returns (bool) {
        return !exceeds(type(uint256).max);
    }

    /// @notice If number > 0, it must exceed (number - 1).
    function echidna_exceeds_predecessor() public view returns (bool) {
        if (number > 0) {
            return exceeds(number - 1);
        }
        return true;
    }

    /// @notice reset() always zeroes the counter — verified by calling it inline.
    function echidna_reset_zeroes() public returns (bool) {
        reset();
        return number == 0;
    }
}
