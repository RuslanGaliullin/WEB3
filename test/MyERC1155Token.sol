pragma solidity ^0.8.9;

import "forge-std/Test.sol"; // Import Foundry's test framework
import "../src/MyERC1155Token.sol"; // Import your ERC721 contract

contract MyERC1155TokenTest is Test {
    // Contract instance and test accounts
    MyERC1155Token public myERC1155Token;
    address public owner = address(1); // Owner of the contract
    address public buyer = address(2); // Buyer address

    uint256 public tokenPrice = 1 ether; // Set the price of the NFT

    function setUp() public {
        // Give both the owner and buyer some ETH
        vm.deal(owner, 10 ether); // Owner starts with 10 ether
        vm.deal(buyer, 10 ether); // Buyer starts with 10 ether

        // Deploy the myERC1155Token contract by "owner"
        vm.prank(owner); // Set the next transaction as being sent from "owner"
        myERC1155Token = new MyERC1155Token(owner, tokenPrice); // Setting the price to 1 Ether

        // Моделируем передачу токенов на контракт, чтобы подготовить их к продаже (tokenId = 1)
        // vm.prank(owner);
        // myERC1155Token.setApprovalForAll(buyer, true); // Владелец одобряет контракт для использования токенов
    }

    /// @notice Test the purchase of an NFT
    function testBuyNFT() public {
        // Mint an NFT (Token 1) and prepare the smart contract for sale
        vm.prank(owner);
        myERC1155Token.mint(1, 2 * 10 ** 18, ""); // The contract owns it

        // Check the contract owns tokenId 1 before the purchase
        assertEq(myERC1155Token.balanceOf(address(myERC1155Token), 1), 2 * 10 ** 18);

        // Buyer buys tokenId 1 (Token price is 1 ETH)
        vm.prank(buyer); // Simulate the buyer calling the function
        myERC1155Token.buy{value: tokenPrice}(1, 1); // Send 1 ETH to buy token 1

        // Check that the buyer owns the token after the transaction
        assertEq(myERC1155Token.balanceOf(buyer, 1), 1); // Buyer should own the token now
    }

    /// @notice Test that the owner can mint an NFT to the smart contract for sale
    function testMintNFT() public {
        vm.prank(owner); // Simulate the owner calling
        myERC1155Token.mint(1, 100, ""); // The contract owns it

        // Check that the contract owns the token
        assertEq(myERC1155Token.balanceOf(address(myERC1155Token), 1), 100);
    }

    /// @notice Test insufficient funds when buying an NFT
    function testBuyWithLowEtherShouldFail() public {
        // Mint an NFT (Token 1)
        vm.prank(owner);
        myERC1155Token.mint(1, 100, ""); // The contract owns it

        // Trying to buy a token with insufficient ether should fail
        vm.prank(buyer);
        vm.expectRevert(bytes("Insufficient funds to buy the tokens"));
        myERC1155Token.buy{value: 0.5 ether}(1, 1); // Attempt to buy with only 0.5 ETH, should revert
    }
}
