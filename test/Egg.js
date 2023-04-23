const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("Egg Contract - feedLevellingRate", function () {

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

    it("should return correct value based on duck weight", async function () {
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