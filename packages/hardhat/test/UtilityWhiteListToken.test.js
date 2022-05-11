const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("WhiteList Token", async () => {
    let UtilityWhiteListToken;
    let whiteListToken;
    const initialValue = ethers.utils.parseEther('1000')
    const mintValue = ethers.utils.parseEther('10')
    const [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();

    beforeEach(async () => {
        UtilityWhiteListToken = await ethers.getContractFactory("UtilityWhiteListToken");
        whiteListToken = await UtilityWhiteListToken.connect(owner).deploy("Test-Token", "TT", initialValue, [owner.address, addr1.address, addr2.address]);
        await whiteListToken.deployed();
    });
    it("Transfer to WhiteList address", async () => {
        await whiteListToken.addToWhiteList(owner.address);
        await whiteListToken.transfer(addr1.address, 50);
        expect(await whiteListToken.balanceOf(addr1.address)).to.equal(50);
    });

    it("Does not exist address", async () => {
        await expect(whiteListToken.transfer(addr3.address, 50)).to.be.revertedWith("UtilityWhiteListToken: Does not exist address");
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
        await expect(whiteListToken.transfer(addr4.address, 50)).to.be.revertedWith("UtilityWhiteListToken: Does not exist address");
    });

    it("mint",async () => {
        await whiteListToken.addToWhiteList(addr5.address);
        await whiteListToken.connect(owner).mint(addr5.address, mintValue);
        console.log(await whiteListToken.balanceOf(addr5.address))
        expect(await whiteListToken.balanceOf(addr5.address)).to.eq(mintValue);
        await whiteListToken.connect(addr1).mint(addr2.address, mintValue)
    });
    it("burn",async () => {
        await whiteListToken.addToWhiteList(ethers.constants.AddressZero);
        await whiteListToken.connect(owner).burn(addr5.address, mintValue);
        expect(await whiteListToken.balanceOf(addr5.address)).to.eq(0);
    });
})