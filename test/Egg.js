const { assert, expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Egg Contract - feedLevellingRate", () => {

    let duckContract = null;
    let eggContract = null;

    beforeEach(async () => {
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();

        const Egg = await ethers.getContractFactory("Egg");
        eggContract = await Egg.deploy(duckContract.address);
        await eggContract.deployed();
    });

    it("should return correct value based on duck weight", async () => {
        let tests = [
            { duckKg: 0, expected: 0 },
            { duckKg: 100, expected: 25 },
            { duckKg: 200, expected: 100 },
            { duckKg: 300, expected: 225 },
            { duckKg: 400, expected: 400 },
            { duckKg: 500, expected: 625 },
            { duckKg: 600, expected: 900 },
            { duckKg: 700, expected: 1225 },
            { duckKg: 800, expected: 1600 },
            { duckKg: 900, expected: 2025 },
            { duckKg: 1000, expected: 2500 },
        ]

        for (let i = 0; i < tests.length; i++) {
            const result = await eggContract.feedLevellingRate(tests[i].duckKg);
            assert.equal(result, tests[i].expected);
        }
    });
});

describe("Egg Contract - cooldownRate", () => {

    let duckContract = null;
    let eggContract = null;

    beforeEach(async () => {
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();

        const Egg = await ethers.getContractFactory("Egg");
        eggContract = await Egg.deploy(duckContract.address);
        await eggContract.deployed();
    });

    it("should return correct value based on duck weight", async () => {
        let tests = [
            { duckKg: 0, expected: 0 },
            { duckKg: 100, expected: 7200 },
            { duckKg: 200, expected: 14400 },
            { duckKg: 300, expected: 21600 },
            { duckKg: 400, expected: 28800 },
            { duckKg: 500, expected: 36000 },
            { duckKg: 600, expected: 43200 },
            { duckKg: 700, expected: 50400 },
            { duckKg: 800, expected: 57600 },
            { duckKg: 900, expected: 64800 },
            { duckKg: 1000, expected: 72000 },
        ]

        for (let i = 0; i < tests.length; i++) {
            const result = await eggContract.cooldownRate(tests[i].duckKg);
            assert.equal(result, tests[i].expected);
        }
    });

});


describe("Egg Contract - stake", () => {

    let owner = null;
    let other = null;
    let duckContract = null;
    let eggContract = null;

    beforeEach(async () => {
        [owner, other] = await ethers.getSigners();

        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();

        const Egg = await ethers.getContractFactory("Egg");
        eggContract = await Egg.deploy(duckContract.address);
        await eggContract.deployed();

        await duckContract.mint();
        duckContract.setWeight(1, 100);
    });

    it("should revert if sender is not the owner", async () => {
        await expect(eggContract.connect(other).stake(1)).to.be.revertedWith("not the owner");
    });

    it("should revert if already staked", async () => {
        await eggContract.stake(1);
        await expect(eggContract.stake(1)).to.be.revertedWith("already staked");
    });

    it("should stake the duck", async () => {
        await eggContract.stake(1);
        const [weight, _ts, _feed, _cooldown] = await eggContract.getStakedDuck(1);
        expect(weight).to.be.greaterThan(0);
    });

});

describe("Egg Contract - unstake", () => {

    let owner = null;
    let other = null;
    let duckContract = null;
    let eggContract = null;

    beforeEach(async () => {
        [owner, other] = await ethers.getSigners();

        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();

        const Egg = await ethers.getContractFactory("Egg");
        eggContract = await Egg.deploy(duckContract.address);
        await eggContract.deployed();

        await duckContract.mint();
        duckContract.setWeight(1, 100);
    });

    it("should revert if sender is not the owner", async () => {
        await eggContract.stake(1);
        await expect(eggContract.connect(other).unstake(1)).to.be.revertedWith("not the owner");
    });

    it("should revert if not staked", async () => {
        await expect(eggContract.unstake(1)).to.be.revertedWith("not staked");
    });

    it("should unstake the duck", async () => {
        await eggContract.stake(1);
        await eggContract.unstake(1);
        const [weight, _ts, _feed, _cooldown] = await eggContract.getStakedDuck(1);
        expect(weight).to.equal(0);
    });

});

describe("Egg Contract - upgradeDuck", () => {

    let owner = null;
    let other = null;
    let duckContract = null;
    let eggContract = null;

    beforeEach(async () => {
        [owner, other] = await ethers.getSigners();

        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();

        const Egg = await ethers.getContractFactory("Egg");
        eggContract = await Egg.deploy(duckContract.address);
        await eggContract.deployed();

        await duckContract.mint();
        duckContract.setWeight(1, 100);
    });

    it("should revert if not staked", async () => {
        await expect(eggContract.upgradeDuck(1)).to.be.revertedWith("not staked");
    });

    it("should revert if not enough feed", async () => {
        await eggContract.stake(1);
        await expect(eggContract.upgradeDuck(1)).to.be.revertedWith("not fed enough");
    });

    it("should revert if not enough time passed", async () => {
        await eggContract.stake(1);
        await eggContract.feed(1, ethers.utils.parseEther("100").toBigInt());
        await expect(eggContract.upgradeDuck(1)).to.be.revertedWith("still cooling down");
    });

    it("should revert if not the owner", async () => {
        await eggContract.stake(1);
        await eggContract.feed(1, ethers.utils.parseEther("100").toBigInt());
        await time.increase(7200);
        await expect(eggContract.connect(other).upgradeDuck(1)).to.be.revertedWith("not the owner");
    });

});