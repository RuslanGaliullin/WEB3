// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

/**
 * @title MyERC1155Token
 * @dev ERC1155 token contract that supports minting, buying, and transferring tokens.
 * It also uses URI storage for metadata and is ownable.
 */
contract MyERC1155Token is ERC1155, ERC1155URIStorage, ERC1155Holder, Ownable {
    uint256 private tokenIds = 1;

    /// @dev Constants representing the token types
    uint256 public constant NFT_ID = 1;
    uint256 public constant TOKEN_ID = 0;

    uint256 private PRICE = 1;
    uint256 public constant MAX_ELEMENTS = 7;

    /**
     * @dev Constructor to initialize the contract with the initial owner and token price.
     * Mints an initial supply of tokens to the contract owner.
     * @param initialOwner The address that will be the owner of the contract.
     * @param _PRICE The price of each token in wei.
     */
    constructor(
        address initialOwner,
        uint256 _PRICE
    )
        ERC1155(
            "https://ipfs.io/ipfs/QmfGCCNUfTCd7thUP5FGd9AuvdRQ4MmNDcH13aGBbGAae9/"
        )
        Ownable(initialOwner)
    {
        _mint(address(this), TOKEN_ID, 10 ** 18, "0x"); // Mint initial supply of fungible tokens
        PRICE = _PRICE;
    }

    /**
     * @notice Buy a specified number of NFTs by sending Ether.
     * @dev Mints new NFTs to the specified address.
     * @param _to The address to mint the NFTs to.
     * @param _count The number of NFTs to mint.
     * Requirements:
     * - `_count` tokens must not exceed the max token limit (`MAX_ELEMENTS`).
     * - The value sent must be equal to or greater than the price of `_count` NFTs.
     */
    function buyNFT(address _to, uint256 _count) public payable {
        require(tokenIds + _count < MAX_ELEMENTS, "Max limit exceeded");
        require(msg.value >= PRICE * _count, "Value below price");

        uint id = tokenIds;
        tokenIds++;
        _mint(_to, id, _count, "");
    }

    /**
     * @notice Buy fungible tokens by sending Ether.
     * @dev Transfers tokens from the contract to the buyer.
     * @param amount The amount of tokens to buy.
     * Requirements:
     * - The value sent must be equal to or greater than the total price of `amount` tokens.
     * - The contract must have enough tokens to fulfill the purchase.
     */
    function buy(address _to, uint256 amount) public payable {
        uint256 totalPrice = PRICE * amount; // Calculate the total price for the amount of tokens
        require(
            msg.value >= totalPrice,
            "Insufficient funds to buy the tokens"
        );
        require(
            balanceOf(address(this), TOKEN_ID) >= amount,
            "Not enough tokens available for sale"
        );

        // Transfer tokens from the contract to the buyer
        this.safeTransferFrom(address(this), _to, TOKEN_ID, amount, "0x");
    }

    /**
     * @notice Returns the metadata URI for a given token ID.
     * @dev Overrides the `uri` function from `ERC1155` and `ERC1155URIStorage`.
     * @param _id The token ID to query.
     * @return The URI associated with the token ID.
     */
    function uri(
        uint256 _id
    ) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return super.uri(_id);
    }

    /**
     * @notice Mint multiple token types in a batch.
     * @dev Only the owner can call this function.
     * @param to The address to mint the tokens to.
     * @param ids An array of token IDs to mint.
     * @param amounts An array of amounts corresponding to each token ID.
     * @param data Additional data to pass along with the mint operation.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @notice Transfers tokens safely from one address to another.
     * @dev Overrides the `safeTransferFrom` function from `ERC1155`.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param tokenId The ID of the token to transfer.
     * @param amount The amount of tokens to transfer.
     * @param data Additional data to include with the transfer.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public override {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    /**
     * @notice Transfers multiple token types safely in a batch.
     * @dev Overrides the `safeBatchTransferFrom` function from `ERC1155`.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param ids An array of token IDs to transfer.
     * @param amounts An array of amounts corresponding to each token ID.
     * @param data Additional data to include with the transfer.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @notice Supports interface function to check the compatibility of the contract.
     * @dev Overrides the supportsInterface function to check for both ERC1155 and ERC1155URIStorage.
     * @param interfaceId The interface identifier, as specified in ERC-165.
     * @return Returns true if the contract supports the given interface.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, ERC1155Holder) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
