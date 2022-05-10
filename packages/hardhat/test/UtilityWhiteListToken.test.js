const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("WhiteList Token", () => {
    let owner, addr1, addr2;
    let UtilityWhiteListToken;
    let whiteListToken;

    beforeEach(async () => {
        [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
        UtilityWhiteListToken = await ethers.getContractFactory("UtilityWhiteListToken");
        whiteListToken = await UtilityWhiteListToken.deploy("Test-Token", "TT", 1000, [owner.address, addr1.address, addr2.address]);
        await whiteListToken.deployed();
    });
    it("Transfer to WhiteList address", async () => {
        await whiteListToken.transfer(addr1.address, 50);
        expect(await whiteListToken.balanceOf(addr1.address)).to.equal(50);
    });

    it("Does not exist address", async () => {
        await expect(whiteListToken.transfer(addr3.address, 50)).to.be.revertedWith("Does not exist address");
        expect(await whiteListToken.balanceOf(addr3.address)).to.equal(0);
    });

    it("Should add an Address to WhiteList",async () => {
        await whiteListToken.addToWhiteList(addr4.address);
        await whiteListToken.transfer(addr4.address, 50);

        expect(await whiteListToken.balanceOf(addr4.address)).to.equal(50);
    });

    it("Should remove an Address from WhiteList",async () => {
        await whiteListToken.addToWhiteList(addr4.address);
        await whiteListToken.transfer(addr4.address, 50);
        expect(await whiteListToken.balanceOf(addr4.address)).to.equal(50);

        await whiteListToken.removeFromWhiteList(addr4.address);
        await expect(whiteListToken.transfer(addr4.address, 50)).to.be.revertedWith("Does not exist receiver address");
    });
})