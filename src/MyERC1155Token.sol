// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract MyERC1155Token is ERC1155, Ownable, ERC1155Holder {
    uint256 private etherPerToken;

    constructor(address initialOwner, uint256 _etherPerToken) ERC1155("") Ownable(initialOwner) {
        etherPerToken = _etherPerToken;
    }

    /**
     * @dev Allows users to buy tokens.
     * @param tokenId The type of token to be purchased (each token type has a specific `tokenId`).
     * @param amount The number of tokens to purchase.
     */
    function buy(uint256 tokenId, uint256 amount) public payable {
        uint256 totalPrice = etherPerToken * amount; // Calculate the total price for the amount of tokens
        require(msg.value >= totalPrice, "Insufficient funds to buy the tokens");
        require(balanceOf(address(this), tokenId) >= amount, "Not enough tokens available for sale");

        // Transfer tokens from the contract to the buyer
        this.safeTransferFrom(address(this), msg.sender, tokenId, amount, "");

        // If excess Ether is sent, refund the difference
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, ERC1155Holder)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
