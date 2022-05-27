const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("Whitelist test", async () => {
    let WhiteListContract, whitelist, admin, addr1, addr2;
    
    beforeEach(async () => {
        [admin, addr1, addr2] = await ethers.getSigners();
        WhiteListContract = await ethers.getContractFactory("Whitelist");
        whitelist = await WhiteListContract.deploy(admin.address, [addr1.address]);
        await whitelist.deployed();
    });

    it("Check initial args (Admin, operator, not operator)", async () => {
        expect(await whitelist.isOperator(addr1.address)).to.equal(true);
        expect(await whitelist.isOperator(addr2.address)).to.equal(false);
        expect(await whitelist.owner()).to.equal(admin.address);
    });

    describe("Operator func test", () => {

        it("Add operator", async () => {
            expect(await whitelist.isOperator(addr2.address)).to.equal(false);
            await whitelist.addOperator(addr2.address)
            expect(await whitelist.isOperator(addr2.address)).to.equal(true);
        });

        it("Do not allow not admin to add operator", async () => {
            expect(await whitelist.isOperator(addr2.address)).to.equal(false);
            await expect(whitelist.connect(addr1).addOperator(addr2.address)).to.be.reverted;
            expect(await whitelist.isOperator(addr2.address)).to.equal(false);
        });
        

        it("Remove operator", async () => {
            expect(await whitelist.isOperator(addr1.address)).to.equal(true);
            await whitelist.removeOperator(addr1.address)
            expect(await whitelist.isOperator(addr1.address)).to.equal(false);
        });

        it("Do not allow not admin to remove operator", async () => {
            expect(await whitelist.isOperator(addr1.address)).to.equal(true);
            await expect(whitelist.connect(addr2).removeOperator(addr1.address)).to.be.reverted;
            expect(await whitelist.isOperator(addr1.address)).to.equal(true);
        });
    });

    describe("Token and isRegistered func test", async ()=> {
        let token;
        beforeEach(async () => {
            const Token = await ethers.getContractFactory("Token");
            token = await Token.deploy("TokenA", "TKA", 10000);
        
            await token.deployed();
        });
        it("Add token to wl", async () => {
            expect(await whitelist.isRegistered(token.address)).to.equal(false);
            await whitelist.connect(addr1).addToken(token.address)
            expect(await whitelist.isRegistered(token.address)).to.equal(true);
        });

        it("Do not allow not operator to add token", async () => {
            expect(await whitelist.isRegistered(token.address)).to.equal(false);
            await expect(whitelist.connect(addr2).addToken(token.address)).to.be.reverted;
            expect(await whitelist.isRegistered(token.address)).to.equal(false);
        });

        it("Remove token from wl", async () => {
            expect(await whitelist.isRegistered(token.address)).to.equal(false);
            await whitelist.connect(addr1).addToken(token.address)
            expect(await whitelist.isRegistered(token.address)).to.equal(true);

            await whitelist.connect(addr1).removeToken(token.address);
            expect(await whitelist.isRegistered(token.address)).to.equal(false);

        });
    });

    describe("Whitelist, dewhitelist, isWhitelisted", async () => {
        let token, token2, user1, user2;
        beforeEach(async ()=> {
            const Token = await ethers.getContractFactory("Token");
            token = await Token.deploy("TokenA", "TKA", 10000);
            token2 = await Token.deploy("TokenB", "TKA", 1000000);
        
            await token.deployed();
            await token2.deployed();
            await whitelist.connect(addr1).addToken(token.address);

            [user1, user2] = await ethers.getSigners(); 
        });

        it("add user to Whitelist", async () => {
            expect(await whitelist.isWhitelisted(token.address, user1.address)).to.equal(false);
            await whitelist.connect(addr1).whitelist(token.address, user1.address);
            expect(await whitelist.isWhitelisted(token.address, user1.address)).to.equal(true);
        });

        it("add user to Whitelist with not registered token", async () => {
            await expect(whitelist.connect(addr1).whitelist(token2.address, user1.address)).to.be.reverted;
        });

        it("remove user from Whitelist", async () => {
            expect(await whitelist.isWhitelisted(token.address, user1.address)).to.equal(false);
            await whitelist.connect(addr1).whitelist(token.address, user1.address);
            expect(await whitelist.isWhitelisted(token.address, user1.address)).to.equal(true);
            
            await whitelist.connect(addr1).dewhitelist(token.address, user1.address);
            expect(await whitelist.isWhitelisted(token.address, user1.address)).to.equal(false);

        });
    });

});