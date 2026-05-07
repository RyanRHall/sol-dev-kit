// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {PredictionMarket} from "@src/PredictionMarket.sol";

import {BaseFuzz} from "@test/echidna/BaseFuzz.echidna.sol";
import {TestERC20} from "@test/mocks/TestERC20.sol";

contract PredictionMarketFuzz is BaseFuzz {
    PredictionMarket private MARKET;
    TestERC20 private TOKEN;

    address private immutable MARKET_OWNER;
    address private immutable ORACLE;

    uint256 private MARKET_ID;

    constructor() {
        MARKET_OWNER = makeAddr("Market Owner");
        ORACLE = makeAddr("Oracle");

        TOKEN = new TestERC20();

        hevm.startPrank(MARKET_OWNER);
        MARKET = new PredictionMarket(TOKEN);
        MARKET_ID = MARKET.createMarket(ORACLE);
        hevm.stopPrank();

        TOKEN.mint(actors[0], 1000 ether);
        TOKEN.mint(actors[1], 1000 ether);
        TOKEN.mint(actors[2], 1000 ether);

        hevm.prank(actors[0]);
        TOKEN.approve(address(MARKET), type(uint256).max);
        hevm.prank(actors[1]);
        TOKEN.approve(address(MARKET), type(uint256).max);
        hevm.prank(actors[2]);
        TOKEN.approve(address(MARKET), type(uint256).max);
    }

    function deposit(uint16 amount) public useRandomActor {
        MARKET.deposit(MARKET_ID, amount);
    }

    function resolve(bool isYes) public {
        PredictionMarket.Market memory market = MARKET.getMarket(MARKET_ID);
        uint256 winningID = isYes ? market.yesID : market.noID;
        hevm.startPrank(ORACLE);
        MARKET.resolve(MARKET_ID, winningID);
        hevm.stopPrank();
    }

    function redeem(uint16 amount) public useRandomActor {
        MARKET.redeem(MARKET_ID, amount);
    }

    function claim() public useRandomActor {
        MARKET.claim(MARKET_ID);
    }

    function transfer(uint256 receiverSeed, uint16 amount, bool isYes) public useRandomActor {
        PredictionMarket.Market memory market = MARKET.getMarket(MARKET_ID);

        uint256 tokenID = isYes ? market.yesID : market.noID;
        address receiver = actors[receiverSeed % actors.length];

        MARKET.safeTransferFrom(msg.sender, receiver, tokenID, amount, "");
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         INVARIANTS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function echidna_market_id_is_valid() public view returns (bool) {
        PredictionMarket.Market memory market = MARKET.getMarket(MARKET_ID);
        return market.winningID == 0 || market.winningID == market.yesID || market.winningID == market.noID;
    }

    function echidna_USDC_supply_is_consistent() public view returns (bool) {
        return TOKEN.balanceOf(actors[0]) + TOKEN.balanceOf(actors[1]) + TOKEN.balanceOf(actors[2])
                + TOKEN.balanceOf(address(MARKET)) == TOKEN.totalSupply();
    }

    function echidna_collateral_and_position_supplies_are_consistent() public view returns (bool) {
        PredictionMarket.Market memory market = MARKET.getMarket(MARKET_ID);

        uint256 yesSupply = MARKET.balanceOf(actors[0], market.yesID) + MARKET.balanceOf(actors[1], market.yesID)
            + MARKET.balanceOf(actors[2], market.yesID);
        uint256 noSupply = MARKET.balanceOf(actors[0], market.noID) + MARKET.balanceOf(actors[1], market.noID)
            + MARKET.balanceOf(actors[2], market.noID);
        uint256 winningSupply = MARKET.balanceOf(actors[0], market.winningID)
            + MARKET.balanceOf(actors[1], market.winningID) + MARKET.balanceOf(actors[2], market.winningID);

        if (market.winningID == 0) {
            // before resolving, the supply of all tokens is 2X the collaterall
            return (yesSupply + noSupply) * 1 ether == TOKEN.balanceOf(address(MARKET)) * 2;
        } else {
            // after resolving, the supply of the winning token is equal to the collateral
            return winningSupply * 1 ether == TOKEN.balanceOf(address(MARKET));
        }
    }
}
