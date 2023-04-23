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

    it("should reset token price and listed status", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        await duckContract.connect(buyer)
            .buyToken(1, {value: ethers.utils.parseEther("1")});

        const duckling = await duckContract.getDuckling(1);

        expect(duckling.price).to.be.equal(0);
        expect(duckling.forSale).to.be.false;
    })
});

describe("Duck Contract - listToken", () => {

    let duckContract = null;
    let owner = null;
    let other = null;

    beforeEach(async () => {
        [owner, other] = await ethers.getSigners();
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();
        await duckContract.mint();
    });

    it("should revert when token is not owned by sender", async () => {
        await expect(duckContract.connect(other).listToken(1, ethers.utils.parseEther("1").toBigInt()))
            .to.be.revertedWith("not the owner");
    });

    it("should revert when token is already listed", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        await expect(duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt()))
            .to.be.revertedWith("token already listed");
    });

    it("should revert when token does not exist", async () => {
        await expect(duckContract.listToken(69, ethers.utils.parseEther("1").toBigInt()))
            .to.be.revertedWith("ERC721: invalid token ID");
    });

    it("should revert when price is 0", async () => {
        await expect(duckContract.listToken(1, 0))
            .to.be.revertedWith("wrong price");
    });

    it("should be returned in listed tokens", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        let listedTokens = await duckContract.getListedTokens();
        expect(listedTokens.length).to.be.equal(1);
    })

    it("should update token attributes after listing", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        const duckling = await duckContract.getDuckling(1);

        expect(duckling.price).to.be.equal(ethers.utils.parseEther("1").toBigInt());
        expect(duckling.forSale).to.be.true;
    });

});

describe("Duck Contract - unlistToken", () => {

    let duckContract = null;
    let owner = null;
    let other = null;

    beforeEach(async () => {
        [owner, other] = await ethers.getSigners();
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();
        await duckContract.mint();
    });

    it("should revert when token is not owned by sender", async () => {
        await expect(duckContract.connect(other).unlistToken(1))
            .to.be.revertedWith("not the owner");
    });

    it("should revert when token is not listed", async () => {
        await expect(duckContract.unlistToken(1))
            .to.be.revertedWith("token not listed");
    });

    it("should revert when token does not exist", async () => {
        await expect(duckContract.unlistToken(69))
            .to.be.revertedWith("ERC721: invalid token ID");
    });

    it("should not be returned in listed tokens", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        await duckContract.unlistToken(1);
        let listedTokens = await duckContract.getListedTokens();
        expect(listedTokens.length).to.be.equal(0);
    });

    it("should update token attributes after unlisting", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        await duckContract.unlistToken(1);
        const duckling = await duckContract.getDuckling(1);

        expect(duckling.price).to.be.equal(0);
        expect(duckling.forSale).to.be.false;
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

describe("Duck Contract - getDuckling", () => {
    let duckContract = null;
    let owner = null;
    let other = null;

    beforeEach(async () => {
        [owner, other] = await ethers.getSigners();
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();
        await duckContract.mint();
    });

    it("should return the correct attributes", async () => {
        const duckling = await duckContract.getDuckling(1);
        expect(duckling.tokenId).to.be.equal(1);
        expect(duckling.owner).to.be.equal(owner.address);
        expect(duckling.price).to.be.equal(0);
        expect(duckling.forSale).to.be.false;
        expect(duckling.weight).to.be.equal(0);
    });

    it("should revert when token does not exist", async () => {
        await expect(duckContract.getDuckling(69)).to.be.revertedWith("invalid token");
    });
});

describe("Duck Contract - getListedTokens", () => {
    let duckContract = null;
    let owner = null;
    let other = null;

    beforeEach(async () => {
        [owner, other] = await ethers.getSigners();
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();
        await duckContract.mint();
    });

    it("should return the correct tokens", async () => {
        await duckContract.listToken(1, ethers.utils.parseEther("1").toBigInt());
        let listedTokens = await duckContract.getListedTokens();
        expect(listedTokens.length).to.be.equal(1);
        expect(listedTokens[0]).to.be.equal(1);
    });

    it("should return an empty array when no token is listed", async () => {
        let listedTokens = await duckContract.getListedTokens();
        expect(listedTokens.length).to.be.equal(0);
    });
});

describe("Duck Contract - getUserTokens", () => {
    let duckContract = null;
    let owner = null;
    let other = null;

    beforeEach(async () => {
        [owner, other] = await ethers.getSigners();
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();
        await duckContract.mint();
    });

    it("should return the correct tokens", async () => {
        await duckContract.transferFrom(owner.address, other.address, 1);
        let userTokens = await duckContract.getUserTokens(other.address);
        expect(userTokens.length).to.be.equal(1);
        expect(userTokens[0]).to.be.equal(1);
    });

    it("should return an empty array when no token is owned by user", async () => {
        let userTokens = await duckContract.getUserTokens(other.address);
        expect(userTokens.length).to.be.equal(0);
    });
});

describe("Duck Contract - setWeight", () => {
    let duckContract = null;
    let owner = null;
    let other = null;

    beforeEach(async () => {
        [owner, other] = await ethers.getSigners();
        const Duck = await ethers.getContractFactory("Duck");
        duckContract = await Duck.deploy();
        await duckContract.deployed();
        await duckContract.mint();
    });

    it("should revert when token is not owned by sender", async () => {
        await expect(duckContract.connect(other).setWeight(1, 1))
            .to.be.revertedWith("not the owner");
    });

    it("should revert when token does not exist", async () => {
        await expect(duckContract.setWeight(69, 1))
            .to.be.revertedWith("ERC721: invalid token ID");
    });

    it("should update token weight", async () => {
        await duckContract.setWeight(1, 1);
        const duckling = await duckContract.getDuckling(1);
        expect(duckling.weight).to.be.equal(1);
    });
});