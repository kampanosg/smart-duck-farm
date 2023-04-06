const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("Duck Contract", function()
{
    it("totalSupply - should return 0 when there are no minted items", async function()
    {
        const Duck = await ethers.getContractFactory("Duck");
        const duckContract = await Duck.deploy();
        await duckContract.deployed();

        const totalSupply = await duckContract.totalSupply();
        expect(totalSupply).to.be.equal(0);
    });

    it("totalSupply - should return correct number when tokens have been minted", async function()
    {
        const Duck = await ethers.getContractFactory("Duck");
        const duckContract = await Duck.deploy();
        await duckContract.deployed();

        await duckContract.mint();
        const totalSupply = await duckContract.totalSupply();
        expect(totalSupply).to.be.equal(1);
    });
});