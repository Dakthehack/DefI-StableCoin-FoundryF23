// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

contract DecentralizedStableCoinTest is Test {
    DecentralizedStableCoin public dsc;
    address public owner;
    address public user = makeAddr("user");
    address public anotherUser = makeAddr("anotherUser");

    uint256 public constant MINT_AMOUNT = 100e18;
    uint256 public constant BURN_AMOUNT = 50e18;

    function setUp() external {
        owner = address(this);
        dsc = new DecentralizedStableCoin();
    }

    //////////////////////////
    // Constructor Tests    //
    //////////////////////////

    function testTokenNameAndSymbol() public view {
        assertEq(dsc.name(), "DecentralizedStableCoin");
        assertEq(dsc.symbol(), "DSC");
    }

    function testOwnerIsSetCorrectly() public view {
        assertEq(dsc.owner(), owner);
    }

    function testInitialSupplyIsZero() public view {
        assertEq(dsc.totalSupply(), 0);
    }

    //////////////////////////
    // Mint Function Tests  //
    //////////////////////////

    function testMintSucceedsWithValidParameters() public {
        dsc.mint(user, MINT_AMOUNT);

        assertEq(dsc.balanceOf(user), MINT_AMOUNT);
        assertEq(dsc.totalSupply(), MINT_AMOUNT);
    }

    function testMintRevertsIfToAddressIsZero() public {
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__NotZeroAddress.selector);
        dsc.mint(address(0), MINT_AMOUNT);
    }

    function testMintRevertsIfAmountIsZero() public {
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__MustBeMoreThanZero.selector);
        dsc.mint(user, 0);
    }

    function testMintRevertsIfCalledByNonOwner() public {
        vm.prank(user);
        vm.expectRevert();
        dsc.mint(user, MINT_AMOUNT);
    }

    function testMintReturnsTrue() public {
        bool result = dsc.mint(user, MINT_AMOUNT);
        assertTrue(result);
    }

    function testMultipleMints() public {
        dsc.mint(user, MINT_AMOUNT);
        dsc.mint(anotherUser, MINT_AMOUNT);

        assertEq(dsc.balanceOf(user), MINT_AMOUNT);
        assertEq(dsc.balanceOf(anotherUser), MINT_AMOUNT);
        assertEq(dsc.totalSupply(), MINT_AMOUNT * 2);
    }

    //////////////////////////
    // Burn Function Tests  //
    //////////////////////////

    modifier mintedTokens() {
        dsc.mint(owner, MINT_AMOUNT);
        _;
    }

    function testBurnSucceedsWithValidAmount() public mintedTokens {
        uint256 initialBalance = dsc.balanceOf(owner);
        uint256 initialSupply = dsc.totalSupply();

        dsc.burn(BURN_AMOUNT);

        assertEq(dsc.balanceOf(owner), initialBalance - BURN_AMOUNT);
        assertEq(dsc.totalSupply(), initialSupply - BURN_AMOUNT);
    }

    function testBurnRevertsIfAmountIsZero() public mintedTokens {
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__MustBeMoreThanZero.selector);
        dsc.burn(0);
    }

    function testBurnRevertsIfAmountExceedsBalance() public mintedTokens {
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__BurnAmountExceedsBalance.selector);
        dsc.burn(MINT_AMOUNT + 1);
    }

    function testBurnRevertsIfCalledByNonOwner() public mintedTokens {
        // Transfer some tokens to user first
        dsc.transfer(user, BURN_AMOUNT);

        vm.prank(user);
        vm.expectRevert();
        dsc.burn(BURN_AMOUNT);
    }

    function testBurnAllTokens() public mintedTokens {
        dsc.burn(MINT_AMOUNT);

        assertEq(dsc.balanceOf(owner), 0);
        assertEq(dsc.totalSupply(), 0);
    }

    function testBurnWithExactBalance() public mintedTokens {
        uint256 balance = dsc.balanceOf(owner);
        dsc.burn(balance);

        assertEq(dsc.balanceOf(owner), 0);
    }

    //////////////////////////
    // Edge Case Tests      //
    //////////////////////////

    function testMintLargeAmount() public {
        uint256 largeAmount = type(uint256).max / 2; // Avoid overflow
        dsc.mint(user, largeAmount);

        assertEq(dsc.balanceOf(user), largeAmount);
    }

    function testBurnAfterTransfer() public mintedTokens {
        // Transfer tokens to another address
        dsc.transfer(user, BURN_AMOUNT);

        // Original owner should not be able to burn transferred tokens
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__BurnAmountExceedsBalance.selector);
        dsc.burn(MINT_AMOUNT);

        // But can burn remaining balance
        dsc.burn(MINT_AMOUNT - BURN_AMOUNT);
        assertEq(dsc.balanceOf(owner), 0);
    }

    function testOwnershipFunctionality() public {
        // Test that ownership can be transferred
        dsc.transferOwnership(user);
        assertEq(dsc.owner(), user);

        // Test that new owner can mint
        vm.prank(user);
        dsc.mint(anotherUser, MINT_AMOUNT);
        assertEq(dsc.balanceOf(anotherUser), MINT_AMOUNT);

        // Test that old owner cannot mint
        vm.expectRevert();
        dsc.mint(anotherUser, MINT_AMOUNT);
    }

    //////////////////////////
    // Inherited ERC20 Tests//
    //////////////////////////

    function testTransferFunctionality() public mintedTokens {
        dsc.transfer(user, BURN_AMOUNT);

        assertEq(dsc.balanceOf(owner), MINT_AMOUNT - BURN_AMOUNT);
        assertEq(dsc.balanceOf(user), BURN_AMOUNT);
    }

    function testApproveFunctionality() public mintedTokens {
        dsc.approve(user, BURN_AMOUNT);
        assertEq(dsc.allowance(owner, user), BURN_AMOUNT);
    }

    function testTransferFromFunctionality() public mintedTokens {
        dsc.approve(user, BURN_AMOUNT);

        vm.prank(user);
        dsc.transferFrom(owner, anotherUser, BURN_AMOUNT);

        assertEq(dsc.balanceOf(owner), MINT_AMOUNT - BURN_AMOUNT);
        assertEq(dsc.balanceOf(anotherUser), BURN_AMOUNT);
        assertEq(dsc.allowance(owner, user), 0);
    }
}
