const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("Duck Contract - mint", () => {

    var duckContract = null;

    beforeEach(async () => {
        const [owner, otherAccount] = await ethers.getSigners();

        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy(
             owner.address,
            "https://duck.com/",
            5,
        );
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
