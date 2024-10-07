const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    // Address of the already deployed contract
    const contractAddress = "0x93f6242bC587258B6fb935d8cE974b39B2aC63D6";

    const Token = await ethers.getContractFactory("MyERC721Token");
    const token = Token.attach(contractAddress);

    console.log("MyERC721Token deployed to:", token);

    //   Now interact with the deployed contract
    // a. mint
    const mintTx = await token.mint(deployer.address, 4, { value: 4 });  // Mint 2 tokens to deployer's address
    await mintTx.wait();
    console.log(`Minted 4 token to ${deployer.address}`);;

    // c. transferFrom
    const approveTx1 = await token.approve(deployer.address, 2);  // Approve tokens for transfer
    await approveTx1.wait();
    const transferFromTx = await token.transferFrom(deployer.address, "0xF9bD56EE66BdD4C3F4a82A1a45fF99b48A33A9c7", 2);  // Transfer tokens on behalf of deployer
    await transferFromTx.wait();
    console.log(`Transferred 2s NFT using transferFrom`);

    // e. safeTransfer
    const approveTx2 = await token.approve(deployer.address, 3);  // Approve tokens for transfer
    await approveTx2.wait();
    const safeTransferTx = await token.safeTransferFrom(deployer.address, "0xF9bD56EE66BdD4C3F4a82A1a45fF99b48A33A9c7", 3);  // Safe transfer 10 tokens
    await safeTransferTx.wait();
    console.log(`Transferred 3s NFT using safe transferFrom`);


    // Указываем слот, где хранится mapping (примерно 0 для balances в простом ERC20 контракте)
    const balanceSlot = 3;

    // Ваш адрес
    const userAddress = deployer.address;

    // Вычисляем слот, где хранится баланс
    const balanceSlotKey = ethers.keccak256(ethers.AbiCoder.defaultAbiCoder().encode(
        ["uint256", "uint256"],
        [userAddress, balanceSlot] // ключ: userAddress, слот: balanceSlot
    ));

    // Используем ethers.js для запроса данных по вычисленному слоту
    const balanceStorage = await ethers.provider.getStorage(contractAddress, balanceSlotKey);

    // Конвертируем данные в формат числа
    const balance = ethers.getBigInt(balanceStorage);

    console.log(`Баланс пользователя ${userAddress}: ${balance}`);

    // Функция для запроса событий Transfer
    async function getTransferEvents() {
        // Фильтр событий Transfer (отправитель и получатель могут быть null, чтобы получить все события)
        const filter = token.filters.Transfer(null, null);
        // Запрос событий Transfer
        const events = await token.queryFilter(filter);

        console.log("Transfer Events:");
        events.forEach((event) => {
            // Аргументы события Transfer включают from, to и tokenId для ERC721
            console.log(`From: ${event.args.from}, To: ${event.args.to}, Token ID: ${event.args.tokenId.toString()}`);
        });
    }

    // Вызываем функции для получения событий
    await getTransferEvents();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
