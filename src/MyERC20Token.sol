// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyERC20Token is ERC20Permit, Ownable {
    uint256 private etherPerToken;
    uint256 public transferFeePercentage; // процент комиссии за перевод

    constructor(address initialOwner, uint256 _etherPerToken, uint256 _transferFeePercentage)
        ERC20("MyToken", "MTK")
        Ownable(initialOwner)
        ERC20Permit("MyToken")
    {
        _mint(msg.sender, 100 * 10 ** decimals());
        etherPerToken = _etherPerToken;
        transferFeePercentage = _transferFeePercentage; // комиссия в %
    }

    // Функция для покупки токенов
    function buy() public payable {
        require(msg.value >= etherPerToken, "Insufficient funds to buy tokens");

        // Рассчитываем количество токенов, исходя из присланного эфира
        uint256 amountToBuy = (msg.value * 10 ** decimals()) / etherPerToken;

        // Проверка, что у контракта достаточно токенов для продажи
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance >= amountToBuy, "Contract doesn't have enough tokens");

        // Переводим токены покупателю
        _transfer(address(this), msg.sender, amountToBuy);
    }

    // Модифицированная функция transfer() с учетом комиссии
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * transferFeePercentage) / 100;
        uint256 amountAfterFee = amount - fee;

        // Отправляем комиссию на указанный кошелек (treasury)
        _transfer(_msgSender(), address(this), fee);

        // Оставшуюся часть средств отправляем получателю
        _transfer(_msgSender(), recipient, amountAfterFee);

        return true;
    }

    // Модифицированная функция transferFrom() с учетом комиссии
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * transferFeePercentage) / 100;
        uint256 amountAfterFee = amount - fee;

        // Списание разрешенного количества токенов
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        // Отправляем комиссию на указанный кошелек (treasury)
        _transfer(sender, address(this), fee);

        // Оставшуюся часть средств отправляем получателю
        _transfer(sender, recipient, amountAfterFee);

        return true;
    }

    // Функция для установки процента комиссии владельцем контракта
    function setTransferFeePercentage(uint256 _transferFeePercentage) external onlyOwner {
        transferFeePercentage = _transferFeePercentage;
    }

    // Функция для владельца, чтобы пополнить контракт токенами для продажи
    function fundContract(uint256 _amount) external onlyOwner {
        _transfer(msg.sender, address(this), _amount);
    }
}
