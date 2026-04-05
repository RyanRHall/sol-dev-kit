// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function test_Decrement() public {
        counter.setNumber(5);
        counter.decrement();
        assertEq(counter.number(), 4);
    }

    function test_DecrementRevertsAtZero() public {
        vm.expectRevert(Counter.Underflow.selector);
        counter.decrement();
    }

    function test_Add() public {
        counter.setNumber(3);
        counter.add(7);
        assertEq(counter.number(), 10);
    }

    function test_Multiply() public {
        counter.setNumber(4);
        counter.multiply(3);
        assertEq(counter.number(), 12);
    }

    function test_MultiplyByZero() public {
        counter.setNumber(99);
        counter.multiply(0);
        assertEq(counter.number(), 0);
    }

    function test_Reset() public {
        counter.setNumber(42);
        counter.reset();
        assertEq(counter.number(), 0);
    }

    function test_ExceedsTrue() public {
        counter.setNumber(10);
        assertTrue(counter.exceeds(9));
    }

    function test_ExceedsFalseWhenEqual() public {
        counter.setNumber(10);
        assertFalse(counter.exceeds(10));
    }

    function test_ExceedsFalseWhenBelow() public {
        counter.setNumber(5);
        assertFalse(counter.exceeds(10));
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }

    function testFuzz_AddThenExceeds(uint256 x) public {
        x = bound(x, 1, type(uint256).max - 1);
        counter.add(x);
        assertTrue(counter.exceeds(x - 1));
        assertFalse(counter.exceeds(x));
    }
}
