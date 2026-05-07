// // SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ERC1155} from "@openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin-contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin-contracts/utils/math/Math.sol";

contract PredictionMarket is ERC1155, Ownable {
    using SafeERC20 for IERC20;

    struct Market {
        uint256 yesID;
        uint256 noID;
        uint256 winningID;
        uint256 liquidityID;
        uint256 lpSupply;
        address oracle;
    }

    IERC20 public immutable COLLATERAL_TOKEN;
    mapping(uint256 marketID => Market market) s_markets;
    uint256 private s_nonce;

    /// @param collateralToken The ERC-20 token used as collateral for all markets
    constructor(IERC20 collateralToken) ERC1155("") Ownable(msg.sender) {
        COLLATERAL_TOKEN = collateralToken;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          MARKETS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @notice Creates a new prediction market with yes/no outcome tokens
    /// @param oracle The address authorized to resolve this market
    /// @return The unique ID of the newly created market
    function createMarket(address oracle) external onlyOwner returns (uint256) {
        uint256 nonce = s_nonce;
        uint256 marketID = _newID(nonce);
        uint256 yesID = _newID(nonce + 1);
        uint256 noID = _newID(nonce + 2);
        uint256 liquidityID = _newID(nonce + 3);

        s_markets[marketID] =
            Market({yesID: yesID, noID: noID, winningID: 0, liquidityID: liquidityID, lpSupply: 0, oracle: oracle});
        s_nonce = nonce + 4;

        return marketID;
    }

    /// @notice Deposits collateral to mint equal amounts of yes and no tokens
    /// @param marketID The ID of the market to deposit into
    /// @param amount The number of yes/no token pairs to mint
    function deposit(uint256 marketID, uint256 amount) external {
        Market memory market = s_markets[marketID];

        require(market.winningID == 0, "market closed");

        _mint(msg.sender, market.yesID, amount, "");
        _mint(msg.sender, market.noID, amount, "");

        COLLATERAL_TOKEN.safeTransferFrom(msg.sender, address(this), amount * 1 ether);
    }

    /// @notice Resolves a market by setting the winning outcome token
    /// @param marketID The ID of the market to resolve
    /// @param winningID The token ID of the winning outcome (must be yesID or noID)
    function resolve(uint256 marketID, uint256 winningID) external {
        Market memory market = s_markets[marketID];

        require(market.oracle == msg.sender, "invalid oracle");
        require(winningID == market.yesID || winningID == market.noID, "invalid winning ID");
        require(market.winningID == 0, "market already resolved");

        s_markets[marketID].winningID = winningID;
    }

    /// @notice Redeems equal amounts of yes and no tokens for collateral before resolution
    /// @param marketID The ID of the market to redeem from
    /// @param amount The number of yes/no token pairs to burn
    function redeem(uint256 marketID, uint256 amount) external {
        Market memory market = s_markets[marketID];

        require(market.winningID == 0, "market closed");

        _burn(msg.sender, market.yesID, amount);
        _burn(msg.sender, market.noID, amount);

        COLLATERAL_TOKEN.safeTransfer(msg.sender, amount * 1 ether);
    }

    /// @notice Claims collateral by burning winning outcome tokens after resolution
    /// @param marketID The ID of the resolved market to claim from
    function claim(uint256 marketID) external {
        Market memory market = s_markets[marketID];

        uint256 claimable = balanceOf(msg.sender, market.winningID);
        _burn(msg.sender, market.winningID, claimable);

        COLLATERAL_TOKEN.safeTransfer(msg.sender, claimable * 1 ether);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            AMM                             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @notice Supplies yes and no tokens as liquidity and receives LP tokens
    /// @param marketID The ID of the market to supply liquidity to
    /// @param yesAmount The amount of yes tokens to deposit
    /// @param noAmount The amount of no tokens to deposit
    function supplyLiquidity(uint256 marketID, uint256 yesAmount, uint256 noAmount) external {
        Market memory market = s_markets[marketID];

        uint256[] memory ids = new uint256[](2);
        (ids[0], ids[1]) = (market.yesID, market.noID);
        uint256[] memory amounts = new uint256[](2);
        (amounts[0], amounts[1]) = (yesAmount, noAmount);

        uint256 yesReserve = balanceOf(address(this), market.yesID);
        uint256 noReserve = balanceOf(address(this), market.noID);
        uint256 lpOwed;

        if (market.lpSupply == 0) {
            lpOwed = Math.sqrt(yesAmount * noAmount);
        } else {
            lpOwed = Math.min(yesAmount * market.lpSupply / yesReserve, noAmount * market.lpSupply / noReserve);
        }

        s_markets[marketID].lpSupply = market.lpSupply + lpOwed;

        _safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
        _mint(msg.sender, market.liquidityID, lpOwed, "");
    }

    /// @notice Burns LP tokens to withdraw a proportional share of yes and no tokens
    /// @param marketID The ID of the market to withdraw liquidity from
    /// @param amount The amount of LP tokens to burn
    function withdrawLiquidity(uint256 marketID, uint256 amount) external {
        Market memory market = s_markets[marketID];

        uint256 yesReserve = balanceOf(address(this), market.yesID);
        uint256 noReserve = balanceOf(address(this), market.noID);
        uint256 yesOwed = (yesReserve * amount) / market.lpSupply;
        uint256 noOwed = (noReserve * amount) / market.lpSupply;

        uint256[] memory ids = new uint256[](2);
        (ids[0], ids[1]) = (market.yesID, market.noID);
        uint256[] memory amounts = new uint256[](2);
        (amounts[0], amounts[1]) = (yesOwed, noOwed);

        s_markets[marketID].lpSupply = market.lpSupply - amount;

        _burn(msg.sender, market.liquidityID, amount);
        _safeBatchTransferFrom(address(this), msg.sender, ids, amounts, "");
    }

    /// @notice Swaps one outcome token for the other through the constant-product AMM (0.3% fee)
    /// @param marketID The ID of the market to swap in
    /// @param tokenInID The token ID of the outcome token being sold
    /// @param amountIn The amount of input tokens to swap
    function swap(uint256 marketID, uint256 tokenInID, uint256 amountIn) external {
        Market memory market = s_markets[marketID];

        require(market.oracle != address(0), "market DNE");
        require(market.winningID == 0, "market closed");
        require(amountIn > 0, "zero in");

        bool isYesIn = false;
        if (tokenInID == market.yesID) {
            isYesIn = true;
        } else if (tokenInID != market.noID) {
            revert("invalid token");
        }

        uint256 tokenOutID = isYesIn ? market.noID : market.yesID;

        uint256 reserveIn = balanceOf(address(this), tokenInID);
        uint256 reserveOut = balanceOf(address(this), tokenOutID);

        require(reserveIn > 0 && reserveOut > 0, "no liquidity");

        // --- fee (0.3%) ---
        uint256 amountOut = (reserveOut * amountIn * 997) / ((reserveIn + amountIn) * 1000);

        require(amountOut < reserveOut, "insufficient liquidity");

        _safeTransferFrom(msg.sender, address(this), tokenInID, amountIn, "");
        _safeTransferFrom(address(this), msg.sender, tokenOutID, amountOut, "");
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          GETTERS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @notice Returns the market struct for a given market ID
    /// @param marketID The ID of the market to query
    /// @return The Market struct containing the market's state
    function getMarket(uint256 marketID) external view returns (Market memory) {
        return s_markets[marketID];
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          PRIVATE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @notice Derives a deterministic ID from the chain ID, contract address, and nonce
    /// @param nonce The nonce used for ID generation
    /// @return The derived unique ID
    function _newID(uint256 nonce) private view returns (uint256) {
        return uint256(keccak256(abi.encode(block.chainid, address(this), nonce)));
    }
}
