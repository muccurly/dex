const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("UtilityWhiteListToken", () => {
    let whiteListToken, whitelist;
    let admin, operator, user1, user2, addr4, addr5;

    beforeEach(async () => {
        [admin, operator, user1, user2, addr4, addr5] = await ethers.getSigners();

        const WhiteListContract = await ethers.getContractFactory("Whitelist");
        whitelist = await WhiteListContract.deploy(admin.address, [operator.address]);
        await whitelist.deployed();

        const UtilityWhiteListToken = await ethers.getContractFactory("UtilityWhiteListToken");
        whiteListToken = await UtilityWhiteListToken.connect(admin).deploy("Test-Token", "TT", whitelist.address);
        await whiteListToken.deployed();

        await whitelist.connect(admin).addOperator(operator.address);

        await whitelist.connect(operator).addToken(whiteListToken.address);
        await whitelist.connect(operator).whitelist(whiteListToken.address, operator.address);
        await whiteListToken.mint(operator.address, 100);
    });

    describe("Transfer whitelist", async () => {

        it("Transfer to WhiteList address", async () => {
            expect(await whitelist.isOperator(operator.address)).to.equal(true);
            await whitelist.connect(operator).whitelist(whiteListToken.address, user1.address);
            expect(await whitelist.isWhitelisted(whiteListToken.address, user1.address)).to.be.equal(true);
            await whiteListToken.connect(operator).transfer(user1.address, 50);
            expect(await whiteListToken.balanceOf(user1.address)).to.equal(50);
        });

        it("Does not exist address in Whitelist", async () => {
            await expect(whiteListToken.connect(operator).transfer(user2.address, 50)).to.be.revertedWith("UtilityWhiteListToken: Does not exist address");
            expect(await whiteListToken.balanceOf(user2.address)).to.equal(0);
        });

    });

    it("mint",async () => {
        await whitelist.connect(operator).addToken(whiteListToken.address);
        await whitelist.connect(operator).whitelist(whiteListToken.address, addr5.address);
        await whiteListToken.mint(addr5.address, 100);
        expect(await whiteListToken.balanceOf(addr5.address)).to.eq(100);
    });

    it("burn",async () => {
        await whiteListToken.connect(admin).burn(operator.address, 100);
        expect(await whiteListToken.balanceOf(operator.address)).to.eq(0);
    });
})