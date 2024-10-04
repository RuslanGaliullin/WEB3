// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol"; // Используем стандартные утилиты для тестов в Foundry
import "../src/MyERC20Token.sol"; // Импортируем наш основной контракт для тестирования
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol"; // Для работы с подписями

contract MyERC20TokenPermitTest is Test {
    // Используем ECDSA для работы с подписями
    using ECDSA for bytes32;

    MyERC20Token private token; // Token для тестирования
    address private owner; // Владелец токена
    address private addr1; // Подписывающая сторона
    uint256 private addr1Pk;
    address private addr2; // Адрес получателя
    uint256 private addr2Pk;

    bytes32 private DOMAIN_SEPARATOR; // Переменная для хранения EIP-712 доменного разделителя (DOMAIN_SEPARATOR)
    uint256 private constant etherPerToken = 0.1 ether; // 0.1 ether = 1 Tokens
    uint256 private constant transferFeePercentage = 0; // 0% комиссия на каждый перевод

    /// Инициализация контракта и приготовление данных перед тестами
    function setUp() public {
        owner = address(this); // Владелец контракта — текущий тестовый контракт
        (addr1, addr1Pk) = makeAddrAndKey("addr1"); // Тестовый адрес 1 через Foundry
        (addr2, addr2Pk) = makeAddrAndKey("addr2"); // Тестовый адрес 1 через Foundry
       
        // Разворачиваем наш контракт
        token = new MyERC20Token(owner, etherPerToken, transferFeePercentage);

        // Трансферим токены на адрес addr1, чтобы у него была сумма для переводов
        token.transfer(addr1, 100 * 10 ** token.decimals());

        // Получаем DOMAIN_SEPARATOR для будущих подписей
        DOMAIN_SEPARATOR = token.DOMAIN_SEPARATOR();
    }

    /// Проверяем permit() с подписями
    function testPermit() public {
        vm.prank(addr1);
        uint256 nonceBefore = token.nonces(addr1); // Получаем текущий nonce у addr1
        uint256 permitValue = 100 * 10 ** token.decimals(); // Пытаемся дать разрешение на 100 токенов
        uint256 deadline = block.timestamp + 1 days; // Срок действия подписи (один день)

        // Собираем данные для EIP-2612 permit
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                addr1, // Владелец (тот, кто подписывает)
                addr2, // Адрес, который будет использовать разрешение
                permitValue, // Сумма разрешаемых для перевода токенов (100 токенов)
                nonceBefore, // Текущий nonce владельца
                deadline // Срок действия подписи
            )
        );

        // Создаем digest сообщения в формате EIP-712
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01", // Префикс для EIP-712
                DOMAIN_SEPARATOR, // Разделитель домена
                structHash // Хэш структуры permit-данных
            )
        );

        // Подпись запроса
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(addr1Pk, digest);

        // Вызываем permit с подписью
        token.permit(addr1, addr2, permitValue, deadline, v, r, s);

        // Проверяем, что nonce увеличился
        uint256 nonceAfter = token.nonces(addr1);
        assertEq(nonceAfter, nonceBefore + 1, "Nonce should increase after permit.");

        // Проверяем, что allowance установлен корректно
        uint256 allowance = token.allowance(addr1, addr2);
        assertEq(allowance, permitValue, "Incorrect allowance.");
    }

    /// Тест permit() и проверка transferFrom
    function testPermitAndTransferFrom() public {
        uint256 permitValue = 100 * 10 ** token.decimals();
        uint256 transferAmount = 50 * 10 ** token.decimals();
        uint256 deadline = block.timestamp + 1 days;
        uint256 nonceBefore = token.nonces(addr1);

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                addr1,
                addr2,
                permitValue,
                nonceBefore,
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(addr1Pk, digest);

        token.permit(addr1, addr2, permitValue, deadline, v, r, s);

        // Проверка увеличения nonce и правильности allowance
        assertEq(token.nonces(addr1), nonceBefore + 1, "Nonce mismatch");
        assertEq(token.allowance(addr1, addr2), permitValue, "Allowance mismatch");

        // Симуляция transferFrom вызова от addr2
        vm.prank(addr2);
        assertTrue(token.transferFrom(addr1, addr2, transferAmount), "Transfer failed");

        // Проверка балансов и уменьшения allowance
        assertEq(token.balanceOf(addr2), transferAmount, "Balance mismatch");
        assertEq(token.allowance(addr1, addr2), permitValue - transferAmount, "Allowance mismatch after transfer");
    }
}
