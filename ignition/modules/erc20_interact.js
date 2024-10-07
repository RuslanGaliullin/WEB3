const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  // Address of the already deployed contract
  const contractAddress = "0x227dc4Cb13f539Ea47E7Db409DE365242Ba684bB";

  const Token = await ethers.getContractFactory("MyERC20Token");
  const token = Token.attach(contractAddress);

  console.log("MyERC20Token deployed to:", token);

  // Now interact with the deployed contract
  // a. mint
  const mintTx = await token.mint(deployer.address, 100);  // Mint 100 tokens to deployer's address
  await mintTx.wait();
  console.log(`Minted 100 tokens to ${deployer.address}`);

  // b. transfer
  const transferTx = await token.transfer("0xF9bD56EE66BdD4C3F4a82A1a45fF99b48A33A9c7", 50);  // Transfer 50 tokens to another address
  await transferTx.wait();
  console.log(`Transferred 50 tokens`);

  // c. transferFrom
  const approveTx = await token.approve(deployer.address, 50);  // Approve tokens for transfer
  await approveTx.wait();
  const transferFromTx = await token.transferFrom(deployer.address, "0xF9bD56EE66BdD4C3F4a82A1a45fF99b48A33A9c7", 50);  // Transfer tokens on behalf of deployer
  await transferFromTx.wait();
  console.log(`Transferred 50 tokens using transferFrom`);

  // d. Buy (если есть функция покупки токенов)
  const buyTx = await token.buy({ value: 10 });  // Покупка токенов за 100 wei
  await buyTx.wait();
  console.log(`Bought tokens`);

  // e. safeTransfer
  const safeTransferTx = await token.safeTransfer("0xF9bD56EE66BdD4C3F4a82A1a45fF99b48A33A9c7", 10);  // Safe transfer 10 tokens
  await safeTransferTx.wait();
  console.log(`Safe transferred 10 tokens`);

  // f. safeMint
  const safeMintTx = await token.safeMint(deployer.address, 10);  // Safe mint 10 tokens
  await safeMintTx.wait();
  console.log(`Safe minted 10 tokens`);

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

  // Функция для запроса событий Transfer
  async function getTransferEvents() {
    const filter = token.filters.Transfer(null, null); // Фильтр событий Transfer
    const events = await token.queryFilter(filter);
    console.log("Transfer Events:");
    events.forEach((event) => {
      console.log(`From: ${event.args.from}, To: ${event.args.to}, Amount: ${event.args.value.toString()}`);
    });
  }

  await getTransferEvents();

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
