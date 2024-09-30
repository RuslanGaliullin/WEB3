// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC1155Token is ERC1155, Ownable {
    uint256 private etherPerToken;
    uint256 public constant TOKEN_ID = 1;

    constructor(address initialOwner, uint256 _etherPerToken) ERC1155("base-uri") Ownable(initialOwner) {etherPerToken = _etherPerToken;}

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }
    
    // Функция для покупки токенов
    function buy(uint256 amountToBuy) public payable {
        require(msg.value >= etherPerToken, "Insufficient ETH sent");

        uint256 contractBalance = balanceOf(address(this), TOKEN_ID);
        require(contractBalance >= amountToBuy, "Not enough tokens in contract");

        // Передаем токены покупателю
        _safeTransferFrom(address(this), msg.sender, TOKEN_ID, amountToBuy, "");
    }

    // Функция для пополнения контракта
    function fundContract(uint256 _amount) external onlyOwner {
        uint256 ownerBalance = balanceOf(owner(), TOKEN_ID);
        require(ownerBalance >= _amount, "Owner doesn't have enough tokens");

        _safeTransferFrom(owner(), address(this), TOKEN_ID, _amount, ""); // Переводим токены владельцем на контракт
    }

    // Функция для изменения курса покупки токенов
    function setTokensPerEther(uint256 _tokensPerEther) external onlyOwner {
        require(_tokensPerEther > 0, "Rate must be greater than zero");
        etherPerToken = _tokensPerEther;
    }

    // Функция для владельца, чтобы вывести эфир с контракта
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner()).transfer(balance);
    }

    // Функция для получения текущего баланса контракта по эфиру
    function getContractEthBalance() public view returns (uint256) {
        return address(this).balance;
    }
}