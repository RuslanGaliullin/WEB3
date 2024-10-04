// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol"; // Import Foundry's test framework
import "../src/MyERC721Token.sol"; // Import your ERC721 contract

contract MyERC721TokenTest is Test {
    // Contract instance and test accounts
    MyERC721Token public myERC721Token;
    address public owner = address(1); // Owner of the contract
    address public buyer = address(2); // Buyer address

    uint256 public tokenPrice = 1 ether; // Set the price of the NFT

    function setUp() public {
        // Give both the owner and buyer some ETH
        vm.deal(owner, 10 ether); // Owner starts with 10 ether
        vm.deal(buyer, 10 ether); // Buyer starts with 10 ether

        // Deploy the MyERC721Token contract by "owner"
        vm.prank(owner); // Set the next transaction as being sent from "owner"
        myERC721Token = new MyERC721Token(owner, tokenPrice); // Setting the price to 1 Ether
    }

    /// @notice Test the purchase of an NFT
    function testBuyNFT() public {
        // Mint an NFT (Token 1) and prepare the smart contract for sale
        vm.prank(owner);
        myERC721Token.safeMint(address(myERC721Token), ""); // The contract owns it

        // Check the contract owns tokenId 1 before the purchase
        assertEq(myERC721Token.ownerOf(0), address(myERC721Token));

        // Buyer buys tokenId 1 (Token price is 1 ETH)
        vm.prank(buyer); // Simulate the buyer calling the function
        myERC721Token.buy{value: tokenPrice}(0); // Send 1 ETH to buy token 1

        // Check that the buyer owns the token after the transaction
        assertEq(myERC721Token.ownerOf(0), buyer); // Buyer should own the token now
    }

    /// @notice Test that the owner can mint an NFT to the smart contract for sale
    function testMintNFT() public {
        vm.prank(owner); // Simulate the owner calling
        myERC721Token.safeMint(address(myERC721Token), ""); // Mint tokenId 1 to the contract

        // Check that the contract owns the token
        assertEq(myERC721Token.ownerOf(0), address(myERC721Token)); // Assert the contract owns tokenId 1
    }

    /// @notice Test insufficient funds when buying an NFT
    function testBuyWithLowEtherShouldFail() public {
        // Mint an NFT (Token 1)
        vm.prank(owner);
        myERC721Token.safeMint(address(myERC721Token), "");

        // Trying to buy a token with insufficient ether should fail
        vm.prank(buyer);
        vm.expectRevert(bytes("Insufficient funds to buy the token"));
        myERC721Token.buy{value: 0.5 ether}(1); // Attempt to buy with only 0.5 ETH, should revert
    }
}
