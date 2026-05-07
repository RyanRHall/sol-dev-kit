pragma solidity ^0.8.20;

import {PredictionMarket} from "@src/PredictionMarket.sol";

import {BaseTest} from "@test/BaseTest.t.sol";
import {TestERC20} from "@test/mocks/TestERC20.sol";

contract PredictionMarketTest is BaseTest {
    PredictionMarket public predictionMarket;
    TestERC20 public collateralToken;
    address public oracle;
    address public user;

    function setUp() public {
        collateralToken = new TestERC20();
        predictionMarket = new PredictionMarket(collateralToken);
        oracle = makeAddr("oracle");
        user = makeAddr("user");
    }

    // Basic unit test example
    function test_CreateMarket_Success() public {
        uint256 marketID = predictionMarket.createMarket(oracle);

        assertNotEq(predictionMarket.getMarket(marketID).yesID, 0);
        assertNotEq(predictionMarket.getMarket(marketID).noID, 0);
        assertEq(predictionMarket.getMarket(marketID).winningID, 0);
        assertNotEq(predictionMarket.getMarket(marketID).liquidityID, 0);
        assertEq(predictionMarket.getMarket(marketID).lpSupply, 0);
        assertEq(predictionMarket.getMarket(marketID).oracle, oracle);
    }

    // Stateless fuzzing example
    function test_Deposit_Success(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount <= type(uint256).max / 1 ether);

        uint256 marketID = predictionMarket.createMarket(oracle);

        vm.startPrank(user);

        collateralToken.mint(user, amount * 1 ether);
        collateralToken.approve(address(predictionMarket), amount * 1 ether);
        predictionMarket.deposit(marketID, amount);

        vm.stopPrank();
    }
}
