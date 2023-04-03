const { expect } = require("chai");
const hre = require("hardhat");

describe("Duck Contract", function () {

  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const Duck = await hre.ethers.getContractFactory("Lock");
    const duck = await Duck.deploy();
  });

});