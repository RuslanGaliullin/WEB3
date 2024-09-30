// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyERC20Token.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyERC20TokenTest is Test {
    MyERC20Token private token;
    address private owner;
    address private addr1;
    address private addr2;

    uint256 private constant etherPerToken = 0.1 ether;  // 0.1 ether = 1 Tokens

    // Этот метод вызывается перед каждым тестом
    function setUp() public {
        owner = address(this); // Владелец — это тестовый контракт
        addr1 = makeAddr("addr1");
        addr2 = makeAddr("addr2");

        // Создание нового токена
        token = new MyERC20Token(owner, etherPerToken);
    }

    // Test: Покупка токенов
    function testBuyTokens() public {
        uint256 etherToSpend = 1 ether;
        uint256 expectedTokens = etherToSpend * 10 ** 18 / etherPerToken;
        uint256 initialSupply = token.totalSupply();

        // Пополняем контракт токенами, чтобы его баланс был для продажи
        token.fundContract(initialSupply);

        // Симулируем покупку токенов пользователем addr1, отправив ему монет
        vm.deal(addr1, etherToSpend);
        vm.prank(addr1);

        // Пользователь addr1 покупает токены
        token.buy{value: etherToSpend}();

        // Проверяем, что баланс addr1 увеличился на ожидаемое количество токенов
        assertEq(token.balanceOf(addr1), expectedTokens);

        // Проверяем, что баланс контракта уменьшился на количество проданных токенов
        assertEq(token.balanceOf(address(token)), initialSupply - expectedTokens); // Начальный поставленный - проданные
    }

    // Test: Ошибка при недостатке токенов на контракте
    function testBuyTokensFailsIfNotEnoughTokensInContract() public {
        // Попытка купить на 1 эфир, недостаточно токенов
        vm.deal(addr1, 1 ether); // Пополняем addr1 эфирами
        vm.prank(addr1); // Делаем запрос от addr1
        vm.expectRevert("Contract doesn't have enough tokens"); // Ожидаем реорт
        token.buy{value: 1 ether}();
    }

    // Test: Ошибка при недостаточности средств пользователя для покупки токенов
    function testBuyTokensFailsIfInsufficientFunds() public {
        // Попытаемся сделать покупку без отправки эфира
        vm.deal(addr1, 1 ether); // Убеждаемся, что у addr1 есть средства
        vm.prank(addr1); // Выполняем транзакцию от addr1
        vm.expectRevert("Insufficient funds to buy tokens"); // Ожидаем сообщение "Insufficient funds"
        token.buy(); // Не передаем ETH, что должно привести к revert
    }
}
