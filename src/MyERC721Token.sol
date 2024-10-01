// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC721Token is ERC721, Ownable, ERC721Holder {
    uint256 private etherPerToken;

    constructor(address initialOwner, uint256 _etherPerToken) ERC721("MyERC721Token", "MTK") Ownable(initialOwner) {
        etherPerToken = _etherPerToken;
    }

    /**
     * @dev Function to buy a token with Ether.
     * Transfers a token from the contract to the buyer if the correct amount is sent.
     * The contract must own the tokens to sell them through this method.
     */
    function buy(uint256 tokenId) public payable {
        require(msg.value >= etherPerToken, "Insufficient funds to buy the token");
        require(ownerOf(tokenId) == address(this), "Token not available for sale"); // Make sure the contract owns the token

        // Transfer the token from the contract to the buyer
        _safeTransfer(address(this), msg.sender, tokenId, "");

        // Optional: If the user sends excess Ether, refund the difference
        if (msg.value > etherPerToken) {
            payable(msg.sender).transfer(msg.value - etherPerToken);
        }
    }

    /**
     * @dev Function to mint tokens.
     * Only the owner can mint tokens, and they will be minted to the contract for later sale.
     */
    function mint(uint256 tokenId) public onlyOwner {
        _safeMint(address(this), tokenId); // Mint token to the contract itself for sale
    }
}
