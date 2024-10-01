// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyERC20Token is ERC20, ERC20Permit, Ownable {
    uint256 private etherPerToken;

    constructor(address initialOwner, uint256 _etherPerToken)
        ERC20("MyToken", "MTK")
        Ownable(initialOwner)
        ERC20Permit("MyToken")
    {
        _mint(msg.sender, 100 * 10 ** decimals());
        etherPerToken = _etherPerToken;
    }

    // Функция для покупки токенов
    function buy() public payable {
        require(msg.value >= etherPerToken, "Insufficient funds to buy tokens");

        // Рассчитываем количество токенов, исходя из присланного эфира
        uint256 amountToBuy = (msg.value * 10**decimals()) / etherPerToken;

        // Проверка, что у контракта достаточно токенов для продажи
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance >= amountToBuy, "Contract doesn't have enough tokens");

        // Переводим токены покупателю
        _transfer(address(this), msg.sender, amountToBuy);
    }

    // Функция для владельца, чтобы пополнить контракт токенами для продажи
    function fundContract(uint256 _amount) external onlyOwner {
        _transfer(msg.sender, address(this), _amount);
    }
}
