// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyERC721Token.sol"; // Путь к вашему контракту

contract MyERC721TokenTest is Test {
    MyERC721Token private nftContract;
    address private owner;
    address private buyer;
    address private nonOwner;

    uint256 constant ETHER_PER_NFT = 0.1 ether; // Цена за один NFT

    function setUp() public {
        // Инициализация
        owner = address(this); // Этот контракт выступает владельцем
        buyer = address(99); // покупатель
        nonOwner = address(888); // не-владелец

        // Создаем экземпляр контракта с ценой 0.1 эфир за NFT
        nftContract = new MyERC721Token(owner, ETHER_PER_NFT);
    }

    /// Тест покупки одного NFT
    function testBuyNFT() public {
        // Даем покупателю достаточно эфира для покупки
        uint256 initialBuyerBalance = 1 ether; // Достаточно для покупки нескольких NFT
        vm.deal(buyer, initialBuyerBalance);

        // Покупатель отправляет эфириум и покупает NFT
        vm.startPrank(buyer); // Все последующие операции будут от имени покупателя

        nftContract.buyNFT{value: ETHER_PER_NFT}(); // Покупка 1 NFT за 0.1 эфира

        // Проверяем, что у покупателя теперь есть 1 NFT
        assertEq(nftContract.balanceOf(buyer), 1);

        // Проверяем, что ID токена 1 принадлежит покупателю
        assertEq(nftContract.ownerOf(1), buyer);
    }

    /// Тест покупки нескольких NFT
    function testBuyMultipleNFTs() public {
        // Даем покупателю достаточно эфира
        uint256 initialBuyerBalance = 1 ether;
        vm.deal(buyer, initialBuyerBalance);

        // Покупаем 2 NFT
        vm.startPrank(buyer);
        nftContract.buyNFT{value: ETHER_PER_NFT}(); // Покупка первого NFT
        nftContract.buyNFT{value: ETHER_PER_NFT}(); // Покупка второго NFT

        // Баланс должен быть 2 NFT
        assertEq(nftContract.balanceOf(buyer), 2);

        // Проверяем владельцев токенов
        assertEq(nftContract.ownerOf(1), buyer); // Первый токен
        assertEq(nftContract.ownerOf(2), buyer); // Второй токен
    }

    /// Тест на недостаточный эфир
    function testBuyNFTFailsWithInsufficientETH() public {
        // Даем покупателю немного эфира, меньше чем нужно
        vm.deal(buyer, 0.05 ether); // Менее чем нужно на покупку одного
        vm.startPrank(buyer);

        // Попытка покупки без достаточного количества эфира должна завершиться неудачей
        vm.expectRevert("Insufficient ETH sent");
        nftContract.buyNFT{value: 0.05 ether}();
    }

    // /// Test only owner can withdraw
    // function testOnlyOwnerCanWithdraw() public {
    //     // 1. Buyer purchases NFT
    //     vm.deal(buyer, 0.2 ether);  // Give buyer some funds to execute transactions
    //     vm.prank(buyer);            // Set buyer as the msg.sender
    //     nftContract.buyNFT{value: ETHER_PER_NFT}();

    //     // 2. Contract now owns the ether: 
    //     assertEq(nftContract.getContractEthBalance(), ETHER_PER_NFT);

    //     // 3. Non-owner tries to withdraw, it reverts
    //     vm.prank(nonOwner);          // Set `nonOwner` as msg.sender
    //     vm.expectRevert(); // Expect revert message from OpenZeppelin
    //     nftContract.withdraw();      // Should fail because non-owner is calling it

    //     // 4. Owner successfully withdraws
    //     vm.prank(owner);             // Set owner as msg.sender
    //     nftContract.withdraw();      // Should succeed as the caller is the owner

    //     assertEq(nftContract.getContractEthBalance(), 0);  // After withdraw, contract balance is 0
    // }
}
