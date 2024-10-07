const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyERC721Token Contract", function () {
    let MyERC721Token, myERC721Token;
    let owner, addr1, addr2;
    const PRICE = 1;
    const maxElements = 7;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners(); // Get signers (accounts)

        // Get the contract factory for MyERC721Token
        MyERC721Token = await ethers.getContractFactory("MyERC721Token");

        // Deploy the contract
        myERC721Token = await MyERC721Token.deploy(owner.address, PRICE);
    });

    describe("Minting", function () {
        it("Should mint tokens and update token count", async function () {
            await myERC721Token.connect(addr1).mint(addr1.address, 2, { value: PRICE * 2 });
            expect(await myERC721Token.totalMint()).to.equal(2);

            await myERC721Token.connect(addr1).mint(addr1.address, 3, { value: PRICE * 3 });
            expect(await myERC721Token.totalMint()).to.equal(5);
        });

        it("Should revert minting if max limit is exceeded", async function () {
            await myERC721Token.connect(addr1).mint(addr1.address, 5, { value: PRICE * 5 });
            await expect(
                myERC721Token.connect(addr1).mint(addr1.address, 3, { value: PRICE * 3 })
            ).to.be.revertedWith("Max limit");
        });

        it("Should revert minting if insufficient funds are sent", async function () {
            await expect(
                myERC721Token.connect(addr1).mint(addr1.address, 2, { value: PRICE })
            ).to.be.revertedWith("Value below price");
        });
    });

    describe("Token Transfers", function () {
        beforeEach(async function () {
            // Mint some tokens to addr1
            await myERC721Token.connect(addr1).mint(addr1.address, 3, { value: PRICE * 3 });
        });

        it("Should transfer token using transferFrom", async function () {
            await myERC721Token.connect(addr1).approve(addr2.address, 1); // Approve tokenId 1 for addr2
            await myERC721Token.connect(addr2).transferFrom(addr1.address, addr2.address, 1);

            expect(await myERC721Token.ownerOf(1)).to.equal(addr2.address);
        });

        it("Should revert transferFrom if not approved or owner", async function () {
            await expect(
                myERC721Token.connect(addr2).transferFrom(addr1.address, addr2.address, 1)
            ).to.be.reverted;
        });

        it("Should transfer token using safeTransferFrom", async function () {
            await myERC721Token.connect(addr1).approve(addr2.address, 2); // Approve tokenId 2 for addr2
            await myERC721Token.connect(addr2)["safeTransferFrom(address,address,uint256)"](addr1.address, addr2.address, 2);

            expect(await myERC721Token.ownerOf(2)).to.equal(addr2.address);
        });

        it("Should revert safeTransferFrom if not approved or owner", async function () {
            await expect(
                myERC721Token.connect(addr2)["safeTransferFrom(address,address,uint256)"](addr1.address, addr2.address, 3)
            ).to.be.reverted;
        });
    });
});
