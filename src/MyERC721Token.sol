// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC721Token is ERC721, ERC721URIStorage, ERC721Holder, Ownable {
    uint256 private _nextTokenId;
    uint256 private _etherPerToken;

    constructor(address initialOwner, uint256 etherPerToken) ERC721("MyERC721Token", "MTK") Ownable(initialOwner) {
        _etherPerToken = etherPerToken;
    }

    /**
     * @dev Function to buy a token with Ether.
     * Transfers a token from the contract to the buyer if the correct amount is sent.
     * The contract must own the tokens to sell them through this method.
     */
    function buy(uint256 tokenId) public payable {
        require(msg.value >= _etherPerToken, "Insufficient funds to buy the token");
        require(ownerOf(tokenId) == address(this), "Token not available for sale"); // Make sure the contract owns the token

        // Transfer the token from the contract to the buyer
        _safeTransfer(address(this), msg.sender, tokenId, "");

        // Optional: If the user sends excess Ether, refund the difference
        if (msg.value > _etherPerToken) {
            payable(msg.sender).transfer(msg.value - _etherPerToken);
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ethereum-blockchain-developer.com/2022-06-nft-truffle-hardhat-foundry/nftdata/";
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
