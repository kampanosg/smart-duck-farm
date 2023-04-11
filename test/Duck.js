const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("Duck Contract - mint", () => {

    let duckContract = null;

    beforeEach(async () => {
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();
    })

    it("should mint a new token", async () => {
        await duckContract.mint();
        const totalSupply = await duckContract.totalSupply();
        expect(totalSupply).to.be.equal(1);
    });

    it("should revert when fee is too low", async () => {
        await expect(duckContract.mint({value: ethers.utils.parseEther("0.5")}))
            .to.be.revertedWith("wrong fee");
    });

    it("should revert when fee is too high", async () => {
        await expect(duckContract.mint({value: ethers.utils.parseEther("1.5")}))
            .to.be.revertedWith("wrong fee");
    });
});

describe("Duck Contract - buyToken", () => {

    let duckContract = null;
    let buyer = null;

    beforeEach(async () => {
        [owner, buyer] = await ethers.getSigners();
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();
        await duckContract.mint();
    })

    it("should revert when buyer is owner", async () => {
        await expect(duckContract.buyToken(1))
            .to.be.revertedWith("already the owner");
    });

    it("should revert when token is not listed", async () => {
        await expect(duckContract.connect(buyer).buyToken(1))
            .to.be.revertedWith("token not listed");
    });

    it("should revert when token does not exist", async () => {
        await expect(duckContract.connect(buyer).buyToken(69))
            .to.be.revertedWith("ERC721: invalid token ID");
    });

    it("should revert when fee is too low", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        await expect(duckContract.connect(buyer).buyToken(1, {value: ethers.utils.parseEther("0.5")}))
            .to.be.revertedWith("wrong fee");
    });

    it("should revert when fee is too high", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        await expect(duckContract.connect(buyer).buyToken(1, {value: ethers.utils.parseEther("1.5")}))
            .to.be.revertedWith("wrong fee");
    });

    it("should transfer token to buyer", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        await duckContract.connect(buyer)
            .buyToken(1, {value: ethers.utils.parseEther("1")});

        const ownerTokens = await duckContract.getUserTokens(buyer.address);
        expect(await duckContract.ownerOf(1)).to.be.equal(buyer.address);
        expect(ownerTokens.length).to.be.equal(1);
        expect(ownerTokens[0]).to.be.equal(1);
    });

    it("should unlist token after transfer", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        await duckContract.connect(buyer)
            .buyToken(1, {value: ethers.utils.parseEther("1")});

        expect(await duckContract.getListedTokens()).to.not.contain(1);
    });
});

describe("Duck Contract - totalSupply", () => {

    let duckContract = null;

    beforeEach(async () => {
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();
    })

    it("should return the supply", async () => {
        await duckContract.mint();
        await duckContract.mint();
        expect(await duckContract.totalSupply()).to.be.equal(2);
    });

    it("should return 0 when no token is minted", async () => {
        expect(await duckContract.totalSupply()).to.be.equal(await duckContract.totalSupply());
    });
});