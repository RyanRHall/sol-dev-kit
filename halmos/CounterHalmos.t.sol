// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

/// @dev Symbolic tests for Counter, intended to run under halmos.
contract CounterHalmosTest is Test {
    Counter counter;

    function setUp() public {
        counter = new Counter();
    }

    // -- setNumber --------------------------------------------------------

    function check_setNumber(uint256 x) public {
        counter.setNumber(x);
        assert(counter.number() == x);
    }

    // -- increment --------------------------------------------------------

    function check_increment(uint256 init) public {
        vm.assume(init < type(uint256).max);
        counter.setNumber(init);
        counter.increment();
        assert(counter.number() == init + 1);
    }

    // -- decrement --------------------------------------------------------

    function check_decrement(uint256 init) public {
        vm.assume(init > 0);
        counter.setNumber(init);
        counter.decrement();
        assert(counter.number() == init - 1);
    }

    function check_decrement_reverts_at_zero() public {
        counter.setNumber(0);
        (bool ok,) = address(counter).call(abi.encodeCall(Counter.decrement, ()));
        assert(!ok);
    }

    // -- add --------------------------------------------------------------

    function check_add(uint256 init, uint256 value) public {
        vm.assume(init <= type(uint256).max - value);
        counter.setNumber(init);
        counter.add(value);
        assert(counter.number() == init + value);
    }

    function check_add_zero_is_identity(uint256 init) public {
        counter.setNumber(init);
        counter.add(0);
        assert(counter.number() == init);
    }

    // -- multiply ---------------------------------------------------------

    function check_multiply(uint256 init, uint256 factor) public {
        unchecked {
            vm.assume(factor == 0 || init <= type(uint256).max / factor);
        }
        counter.setNumber(init);
        counter.multiply(factor);
        assert(counter.number() == init * factor);
    }

    function check_multiply_by_zero(uint256 init) public {
        counter.setNumber(init);
        counter.multiply(0);
        assert(counter.number() == 0);
    }

    function check_multiply_by_one(uint256 init) public {
        counter.setNumber(init);
        counter.multiply(1);
        assert(counter.number() == init);
    }

    // -- reset ------------------------------------------------------------

    function check_reset(uint256 init) public {
        counter.setNumber(init);
        counter.reset();
        assert(counter.number() == 0);
    }

    // -- exceeds ----------------------------------------------------------

    function check_exceeds(uint256 init, uint256 threshold) public {
        counter.setNumber(init);
        bool result = counter.exceeds(threshold);
        assert(result == (init > threshold));
    }

    // -- composite properties ---------------------------------------------

    function check_increment_then_decrement_roundtrip(uint256 init) public {
        vm.assume(init < type(uint256).max);
        counter.setNumber(init);
        counter.increment();
        counter.decrement();
        assert(counter.number() == init);
    }

    function check_set_then_reset(uint256 x) public {
        counter.setNumber(x);
        counter.reset();
        assert(counter.number() == 0);
        assert(!counter.exceeds(0));
    }
}
