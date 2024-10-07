const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyERC1155Token", function () {
  let MyERC1155Token;
  let token;
  let owner;
  let addr1;
  let addr2;
  let initialOwner = "0x0000000000000000000000000000000000000000"; // Placeholder for owner address in tests

  const PRICE = 10; // 10 wei per token
  const TOKEN_ID = 0;
  const NFT_ID = 1;

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    MyERC1155Token = await ethers.getContractFactory("MyERC1155Token");
    token = await MyERC1155Token.deploy(owner.address, PRICE);
  });

  it("Should deploy the contract correctly", async function () {
    expect(await token.owner()).to.equal(owner.address);
  });

  it("Should mint initial tokens to the contract", async function () {
    const contractBalance = await token.balanceOf(token, TOKEN_ID);
    expect(contractBalance).to.equal(1000000000000000000n);
  });

  it("Should allow buying fungible tokens by sending Ether", async function () {
    const buyAmount = 10; // Buy 10 tokens
    const totalPrice = PRICE * buyAmount;

    await expect(
      token.connect(addr1).buy(addr1.address, buyAmount, { value: totalPrice })
    )
      .to.emit(token, "TransferSingle")
      .withArgs(token, token, addr1.address, TOKEN_ID, buyAmount);

    const addr1Balance = await token.balanceOf(addr1.address, TOKEN_ID);
    expect(addr1Balance).to.equal(buyAmount);
  });

  it("Should revert if insufficient Ether is sent for buying fungible tokens", async function () {
    const buyAmount = 10;
    const insufficientValue = PRICE * buyAmount - 1;

    await expect(
      token.connect(addr1).buy(addr1.address, buyAmount, { value: insufficientValue })
    ).to.be.revertedWith("Insufficient funds to buy the tokens");
  });

  it("Should allow minting NFTs", async function () {
    const mintCount = 3;
    const totalPrice = PRICE * mintCount;

    await expect(token.connect(addr1).buyNFT(addr1.address, mintCount, { value: totalPrice }))
      .to.emit(token, "TransferSingle")
      .withArgs(addr1.address, addr1.address, addr1.address, NFT_ID + 1, mintCount);

    const addr1Balance = await token.balanceOf(addr1.address, NFT_ID + 1);
    expect(addr1Balance).to.equal(mintCount);
  });

  it("Should revert if max NFT limit is exceeded", async function () {
    const mintCount = 10; // Exceeds MAX_ELEMENTS (7)

    await expect(
      token.connect(addr1).buyNFT(addr1.address, mintCount, { value: PRICE * (mintCount) })
    ).to.be.revertedWith("Max limit exceeded");
  });

  it("Should allow safe transfers", async function () {
    const transferAmount = 5;
    const totalPrice = PRICE * (transferAmount);

    // First, addr1 buys some tokens
    await token.connect(addr1).buy(addr1.address, transferAmount, { value: totalPrice });

    // Now, addr1 transfers tokens to addr2
    await token
      .connect(addr1)
      .safeTransferFrom(addr1.address, addr2.address, TOKEN_ID, transferAmount, "0x");

    const addr2Balance = await token.balanceOf(addr2.address, TOKEN_ID);
    expect(addr2Balance).to.equal(transferAmount);
  });

  it("Should allow safe batch transfers", async function () {
    const ids = [TOKEN_ID, NFT_ID];
    const amounts = [10, 1];

    // First mint some tokens to addr1
    await token.connect(addr1).buy(addr1.address, 10, { value: PRICE * (10) });
    await token.connect(addr1).buyNFT(addr1.address, 1, { value: PRICE * (1) });

    // Perform a batch transfer
    await token
      .connect(addr1)
      .safeBatchTransferFrom(addr1.address, addr2.address, ids, amounts, "0x");

    const addr2FungibleBalance = await token.balanceOf(addr2.address, TOKEN_ID);
    const addr2NFTBalance = await token.balanceOf(addr2.address, NFT_ID);

    expect(addr2FungibleBalance).to.equal(10);
    expect(addr2NFTBalance).to.equal(1);
  });

  it("Should revert if trying to transfer more tokens than owned", async function () {
    const transferAmount = 100; // Exceeds balance

    await expect(
      token.connect(addr1).safeTransferFrom(addr1.address, addr2.address, TOKEN_ID, transferAmount, "0x")
    ).to.be.reverted;
  });

  it("Should return the correct URI for token ID", async function () {
    const tokenURI = await token.uri(TOKEN_ID);
    expect(tokenURI).to.equal(
      "https://ipfs.io/ipfs/QmfGCCNUfTCd7thUP5FGd9AuvdRQ4MmNDcH13aGBbGAae9/"
    );
  });

  it("Should mint multiple tokens in batch", async function () {
    const ids = [NFT_ID + 1, NFT_ID + 2, NFT_ID + 3];
    const amounts = [1, 1, 1];

    await expect(token.mintBatch(addr1.address, ids, amounts, "0x"))
      .to.emit(token, "TransferBatch")
      .withArgs(owner.address, "0x0000000000000000000000000000000000000000", addr1.address, ids, amounts);

    for (let i = 0; i < ids.length; i++) {
      expect(await token.balanceOf(addr1.address, ids[i])).to.equal(amounts[i]);
    }
  });
});
