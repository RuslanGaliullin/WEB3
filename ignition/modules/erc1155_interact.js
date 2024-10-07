const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    // Address of the already deployed contract
    const contractAddress = "0x419521d220c36185565FBa1Eb57d04Bca1b9eEB6";

    const Token = await ethers.getContractFactory("MyERC1155Token");
    const token = Token.attach(contractAddress);

    console.log("MyERC1155Token deployed to:", token);

    // Now interact with the deployed contract
    const mintTx = await token.buyNFT(deployer.address, 3, { value: 3 });
    await mintTx.wait();
    console.log(`Minted 3 token to ${deployer.address}`);

    const buyTx = await token.buy(deployer.address, 10, { value: 10 });
    await buyTx.wait();
    console.log(`Bought 10 token to ${deployer.address}`);

    const approveTx = await token.setApprovalForAll(deployer.address, true);  // Approve deployer to manage tokens
    await approveTx.wait();
    console.log(`Approved deployer to manage tokens`);

    const safeTransferTx = await token.safeTransferFrom(
        deployer.address,
        "0xF9bD56EE66BdD4C3F4a82A1a45fF99b48A33A9c7",  // Recipient address
        0,  // Token ID (TOKEN_ID in this case)
        5,  // Amount of tokens to transfer
        "0x"  // Additional data
    );
    await safeTransferTx.wait();
    console.log(`Transferred 5 tokens of type 1 using safeTransferFrom`);


    const safeBatchTransferTx = await token.safeBatchTransferFrom(
        deployer.address,
        "0xF9bD56EE66BdD4C3F4a82A1a45fF99b48A33A9c7",  // Recipient address
        [0, 1],  // Array of token IDs
        [5, 1],  // Array of amounts for each token ID
        "0x"  // Additional data
    );
    await safeBatchTransferTx.wait();
    console.log(`Transferred 5 tokens of type 0 and 1 tokens of type 1 using safeBatchTransferFrom`);



    // Указываем слот, где хранится mapping (примерно 0 для balances в простом ERC20 контракте)
    const balanceSlot = 0;

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

    // Функция для запроса событий TransferSingle (например, для ERC1155)
    async function getTransferSingleEvents() {
        const filter = token.filters.TransferSingle(null, null, null); // Фильтр событий TransferSingle
        const events = await token.queryFilter(filter);
        console.log("TransferSingle Events:");
        events.forEach((event) => {
            console.log(`Operator: ${event.args.operator}, From: ${event.args.from}, To: ${event.args.to}, ID: ${event.args.id.toString()}, Amount: ${event.args.value.toString()}`);
        });
    }

    // Функция для запроса событий TransferBatch (например, для ERC1155)
    async function getTransferBatchEvents() {
        const filter = token.filters.TransferBatch(null, null, null); // Фильтр событий TransferBatch
        const events = await token.queryFilter(filter);
        console.log("TransferBatch Events:");
        events.forEach((event) => {
            console.log(`Operator: ${event.args.operator}, From: ${event.args.from}, To: ${event.args.to}, IDs: ${event.args.ids}, Amounts: ${event.args.values}`);
        });
    }

    // Вызываем функции для получения событий
    await getTransferSingleEvents();
    await getTransferBatchEvents();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
