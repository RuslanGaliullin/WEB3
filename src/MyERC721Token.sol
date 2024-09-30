// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC721Token is ERC721, ERC721Enumerable, Ownable {
    uint256 private etherPerToken;
    uint256 private nextTokenId = 1; // Идентификатор для следующего токена

    constructor(address initialOwner, uint256 _etherPerToken) ERC721("MyToken", "MTK") Ownable(initialOwner) {
        etherPerToken = _etherPerToken;
    }

    // Функция для покупки токенов
    function buyNFT() public payable {
        require(msg.value >= etherPerToken, "Insufficient ETH sent");

        _mint(msg.sender, nextTokenId);
        nextTokenId++;
    }

    // Функция для изменения курса покупки токенов
    function setTokensPerEther(uint256 _etherPerToken) external onlyOwner {
        require(_etherPerToken > 0, "Rate must be greater than zero");
        etherPerToken = _etherPerToken;
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
