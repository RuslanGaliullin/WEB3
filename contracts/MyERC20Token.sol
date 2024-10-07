// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title MyERC20Token
 * @dev ERC20 токен с функциями покупки, комиссии за перевод и управляемой минтинга.
 */
contract MyERC20Token is ERC20Permit, Ownable {
    uint256 private etherPerToken;
    uint256 public transferFeePercentage; // процент комиссии за перевод

    /**
     * @dev Конструктор устанавливает владельца, стоимость токена в эфире и процент комиссии за перевод.
     * @param initialOwner Адрес начального владельца контракта.
     * @param _etherPerToken Стоимость одного токена в эфирах.
     * @param _transferFeePercentage Процент комиссии за перевод токенов.
     */
    constructor(address initialOwner, uint256 _etherPerToken, uint256 _transferFeePercentage)
        ERC20("MyToken", "MTK")
        Ownable(initialOwner)
        ERC20Permit("MyToken")
    {
        _mint(msg.sender, 100 * 10 ** decimals()); // Минт 100 токенов для владельца
        etherPerToken = _etherPerToken;
        transferFeePercentage = _transferFeePercentage; // комиссия в %
    }

    /**
     * @notice Покупка токенов за эфир.
     * @dev Пользователь отправляет эфир, и получает соответствующее количество токенов по текущему курсу.
     * Требует, чтобы отправленная сумма была не меньше стоимости одного токена.
     */
    function buy() public payable {
        require(msg.value >= etherPerToken, "Insufficient funds to buy tokens");

        // Рассчитываем количество токенов, исходя из присланного эфира
        uint256 amountToBuy = msg.value / etherPerToken;

        // Проверка, что у контракта достаточно токенов для продажи
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance >= amountToBuy, "Contract doesn't have enough tokens");

        // Переводим токены покупателю
        _transfer(address(this), msg.sender, amountToBuy);
    }

    /**
     * @notice Перевод токенов с учетом комиссии.
     * @dev Процент комиссии удерживается с отправленной суммы и отправляется на кошелек контракта.
     * @param recipient Адрес получателя.
     * @param amount Количество токенов для перевода.
     * @return Возвращает true, если операция прошла успешно.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * transferFeePercentage) / 100;
        uint256 amountAfterFee = amount - fee;

        // Отправляем комиссию на указанный кошелек (treasury)
        _transfer(_msgSender(), address(this), fee);

        // Оставшуюся часть средств отправляем получателю
        _transfer(_msgSender(), recipient, amountAfterFee);

        return true;
    }

    /**
     * @notice Перевод токенов от отправителя с учетом комиссии.
     * @dev Процент комиссии удерживается с отправленной суммы и отправляется на кошелек контракта.
     * @param sender Адрес отправителя.
     * @param recipient Адрес получателя.
     * @param amount Количество токенов для перевода.
     * @return Возвращает true, если операция прошла успешно.
     */
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

    /**
     * @notice Устанавливает новый процент комиссии за перевод.
     * @dev Только владелец контракта может вызвать эту функцию.
     * @param _transferFeePercentage Новый процент комиссии за перевод.
     */
    function setTransferFeePercentage(uint256 _transferFeePercentage) external onlyOwner {
        transferFeePercentage = _transferFeePercentage;
    }

    /**
     * @notice Минт новых токенов для указанного адреса.
     * @dev Только владелец контракта может минтить токены.
     * @param to Адрес получателя новых токенов.
     * @param amount Количество новых токенов.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount); // Минт указанного количества токенов для указанного адреса
    }

    /**
     * @notice Пополнение баланса контракта токенами для дальнейшей продажи.
     * @dev Только владелец контракта может пополнять баланс токенов.
     * @param _amount Количество токенов для перевода на баланс контракта.
     */
    function fundContract(uint256 _amount) external onlyOwner {
        _transfer(msg.sender, address(this), _amount);
    }
}
