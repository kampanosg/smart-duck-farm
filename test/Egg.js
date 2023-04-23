const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

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
