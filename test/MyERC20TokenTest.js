const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyERC20Token", function () {
  let MyERC20Token, token, owner, addr1, addr2;
  const PRICE = 10; // 10 wei = 1 token
  const transferFeePercentage = 2; // 2% fee
  const ownerTokenAmount = 1000; // 100 tokens

  beforeEach(async function () {
    // Get signers and deploy contract
    [owner, addr1, addr2] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("MyERC20Token");
    token = await Token.deploy(owner.address, PRICE, transferFeePercentage);

    // Fund contract with tokens for sale
    await token.fundContract(ownerTokenAmount);
  });

  it("Should allow buying tokens", async function () {
    const etherToSpend = 30;
    const expectedTokens = etherToSpend / PRICE;

    // Send ether to addr1 and have them buy tokens
    await addr1.sendTransaction({ to: owner.address, value: etherToSpend });
    await token.connect(addr1).buy({ value: etherToSpend });

    // Check balances
    expect(await token.balanceOf(addr1.address)).to.equal(expectedTokens);
    expect(await token.balanceOf(token)).to.equal(ownerTokenAmount - expectedTokens);
  });

  it("Should fail if not enough tokens in contract", async function () {
    // Try to buy tokens, expecting a revert
    await expect(token.connect(addr1).buy({ value: 1000000 }))
      .to.be.revertedWith("Contract doesn't have enough tokens");
  });

  it("Should fail if user has insufficient funds", async function () {
    await expect(token.connect(addr1).buy()).to.be.revertedWith("Insufficient funds to buy tokens");
  });

  it("Should correctly set the transfer fee percentage", async function () {
    const newFee = 5; // 5%
    await token.setTransferFeePercentage(newFee);
    expect(await token.transferFeePercentage()).to.equal(newFee);
  });

  it("Should correctly transfer with fee", async function () {
    const transferAmount = ownerTokenAmount;
    const fee = transferAmount * transferFeePercentage / 100;
    const amountAfterFee = transferAmount - fee;

    // Transfer tokens from token to addr1
    await token.transfer(addr1.address, transferAmount);

    // Check balances
    expect(await token.balanceOf(addr1.address)).to.equal(amountAfterFee);
    expect(await token.balanceOf(token)).to.equal(ownerTokenAmount + fee);
  });

  it("Should correctly transferFrom with fee", async function () {
    const transferAmount = ownerTokenAmount;
    const approveAmount = 200000;
    const fee = transferAmount * transferFeePercentage / 100;
    const amountAfterFee = transferAmount - fee;

    // Approve and transfer tokens
    await token.approve(addr1.address, approveAmount);
    await token.connect(addr1).transferFrom(owner.address, addr1.address, transferAmount);

    // Check balances
    expect(await token.balanceOf(addr1.address)).to.equal(amountAfterFee);
    expect(await token.balanceOf(token)).to.equal(ownerTokenAmount + fee);
  });
});
