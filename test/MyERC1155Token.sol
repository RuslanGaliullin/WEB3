// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyERC1155Token.sol"; // Убедитесь, что путь совпадает с именем вашего контракта

contract MyERC1155TokenTest is Test {
    MyERC1155Token private tokenContract;
    address private owner;
    address private buyer;
    uint256 private constant TOKEN_ID = 1;
    uint256 private constant ETHER_PER_TOKEN = 0.1 ether;

    function setUp() public {
        owner = address(this); // Владелец является текущим контрактом в тестах.
        buyer = address(99); // Покупателем выступает этот адрес.

        tokenContract = new MyERC1155Token(owner, ETHER_PER_TOKEN);

        // Проверяем, что токены минтятся для EOA (EOA может принимать ERC1155, без проверки интерфейса)
        tokenContract.mint(owner, TOKEN_ID, 100, ""); // Владелец минтит 100 токенов на себя
    }

    /// Тестируем успешную покупку токенов
    function testSuccessfulBuy() public {
        // Владелец пополняет контракт (переводит 50 токенов на контракт)
        tokenContract.fundContract(50);

        // Покупатель покупает 1 токен, отправив 0.1 Эфир
        vm.deal(buyer, 0.2 ether); // Пополняем счет покупателя 0.2 эфиром
        vm.prank(buyer); // Симулируем что следующие действия выполняет buyer
        tokenContract.buy{value: ETHER_PER_TOKEN}(1); // Покупка 1 токена

        // У покупателя теперь должно быть 1 токен
        assertEq(tokenContract.balanceOf(buyer, TOKEN_ID), 1);

        // Проверяем, сколько токенов осталось на контракте (должно быть 49, т.к. было продано один токен)
        assertEq(tokenContract.balanceOf(address(tokenContract), TOKEN_ID), 49);
    }

    /// Тестируем неудачную покупку токенов при недостатке эфира
    function testInsufficientEthBuy() public {
        // Пополняем контракт 50 токенами
        tokenContract.fundContract(50);

        // Покупатель пытается купить один токен, не отправив достаточно эфира
        vm.deal(buyer, 0.05 ether); // У покупателя 0.05 эфира (меньше, чем необходимо)
        vm.prank(buyer); // Симулируем действия от имени buyer

        // Ожидаем реорот ошибки "Insufficient ETH sent"
        vm.expectRevert("Insufficient ETH sent");
        tokenContract.buy{value: 0.05 ether}(1); // Попытка покупки должна провалиться
    }

    /// Тестируем неудачную покупку, когда на контракте недостаточно токенов
    function testNotEnoughTokensInContract() public {
        // Пополняем контракт только 10 токенами, но пытаемся купить больше
        tokenContract.fundContract(10);

        vm.deal(buyer, 1 ether); // У покупателя хватает эфира для покупки
        vm.prank(buyer);

        // Ожидание ошибки "Not enough tokens in contract"
        vm.expectRevert("Not enough tokens in contract");
        tokenContract.buy{value: ETHER_PER_TOKEN}(20); // Пометка: пытаемся купить больше токенов, чем на контракте
    }

    /// Тестируем пополнение контракта (владелец пополняет токенами)
    function testFundContract() public {
        // Владелец пополняет контракт на 50 токенов
        uint256 initialOwnerBalance = tokenContract.balanceOf(owner, TOKEN_ID); // Баланс владельца до перевода

        tokenContract.fundContract(50); // Переводим 50 токенов на контракт

        // Проверьте баланс контракта (должен теперь содержать 50 токенов)
        assertEq(tokenContract.balanceOf(address(tokenContract), TOKEN_ID), 50);

        // Убедитесь, что баланс владельца уменьшился на 50 токенов
        assertEq(tokenContract.balanceOf(owner, TOKEN_ID), initialOwnerBalance - 50);
    }
}
