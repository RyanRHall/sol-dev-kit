// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {Test} from "forge-std/Test.sol";
import {PredictionMarket} from "@src/PredictionMarket.sol";
import {TestERC20} from "@test/mocks/TestERC20.sol";

contract PredictionMarketHalmosTest is SymTest, Test {
    PredictionMarket public MARKET;
    TestERC20 public TOKEN;
    address public oracle;
    address public user;
    address public marketOwner;
    uint256 public marketID;

    function setUp() public {
        oracle = makeAddr("oracle");
        user = makeAddr("user");
        marketOwner = makeAddr("marketOwner");

        TOKEN = new TestERC20();
        vm.startPrank(marketOwner);
        MARKET = new PredictionMarket(TOKEN);
        marketID = MARKET.createMarket(oracle);
        vm.stopPrank();

        TOKEN.mint(user, svm.createUint256("amount"));
        vm.prank(user);
        TOKEN.approve(address(MARKET), type(uint256).max);
    }

    function check_Deposit(uint256 amount) public {
        vm.assume(amount <= TOKEN.balanceOf(user) / 1 ether);

        vm.prank(user);
        MARKET.deposit(marketID, amount);

        PredictionMarket.Market memory market = MARKET.getMarket(marketID);

        assertEq(TOKEN.balanceOf(address(MARKET)), amount * 1 ether);
        assertEq(MARKET.balanceOf(user, market.yesID), amount);
        assertEq(MARKET.balanceOf(user, market.noID), amount);
    }
}
