const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

const getBalance = ethers.provider.getBalance;

use(solidity);

describe("My dexFactory", function () {
  let dexFactory;
  let tokenA;
  let tokenB;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("Token");
    const Token2 = await ethers.getContractFactory("Token");
    tokenA = await Token.deploy("TokenA", "TKA", 10000);
    tokenB = await Token2.deploy("TokenB", "TKB", 100000);
    await tokenA.deployed();
    await tokenB.deployed();

    const MathLib =  await ethers.getContractFactory("Math");
    const mathLib = await MathLib.deploy();
    await mathLib.deployed();

    const DexFactory = await ethers.getContractFactory("DexFactory", {
        libraries: {
            "Math": mathLib.address
        }
    });
    dexFactory = await DexFactory.deploy();
    await dexFactory.deployed();
  });

  it("is deployed", async () => {
    expect(await dexFactory.deployed()).to.equal(dexFactory);
  });

  describe("createDex", () => {
    it("deploy an exchange", async () => {
        await dexFactory.createDex(tokenB.address, tokenA.address);
        expect(await dexFactory.getPools(tokenA.address, tokenB.address))
        .to.equal(await dexFactory.allPools(0));
    });

    it("should fail to identical tokens", async () => {
        await expect(dexFactory.createDex(tokenA.address, tokenA.address))
        .to.be.revertedWith("Identical Addresses");
    });

    it("doesn't allow zero address", async () => {
        await expect(dexFactory.createDex(tokenA.address, "0x0000000000000000000000000000000000000000"))
        .to.be.revertedWith("Invalid token address");
    });

    it("dex should already exist", async () => {
        await dexFactory.createDex(tokenB.address, tokenA.address);
        expect(await dexFactory.getPools(tokenA.address, tokenB.address))
        .to.equal(await dexFactory.allPools(0));

        await expect(dexFactory.createDex(tokenA.address, tokenB.address))
        .to.be.revertedWith("tokens already exist");
    });
  })

  
});
