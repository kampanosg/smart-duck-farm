const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("Duck Contract - mint", () => {

    var duckContract = null;

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
        await expect(duckContract.mint({value: ethers.utils.parseEther("0.5")})).to.be.revertedWith("wrong fee");
    });

    it("should revert when fee is too high", async () => {
        await expect(duckContract.mint({value: ethers.utils.parseEther("1.5")})).to.be.revertedWith("wrong fee");
    });
});

describe("Duck Contract - totalSupply", () => {

    var duckContract = null;

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