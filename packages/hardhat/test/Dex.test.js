const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

const getBalance = ethers.provider.getBalance;

use(solidity);

describe("My DEX", function () {
  let owner, user;
  let dex;
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

    const Dex = await ethers.getContractFactory("Dex", {
      libraries: {
          "Math": mathLib.address
      }
    });
    dex = await Dex.deploy(tokenA.address, tokenB.address);
    await dex.deployed();
  });

  describe("Add liquidity", async () => {
    describe("empty reserves", async () => {
      it("adds liquidity", async () => {
        await tokenA.approve(dex.address, 100);
        await tokenB.approve(dex.address, 1000);
        await dex.createPool(100, 1000, { value: 100 })
        const t = await dex.getReserve();
        expect(t[0].toString()).to.eql("100");
        expect(t[1].toString()).to.eql("1000");
      });

      it("mints LP tokens", async () => {
        await tokenA.approve(dex.address, 100);
        await tokenB.approve(dex.address, 1000);
        await dex.createPool(100, 1000, { value: 100 });

        expect(await dex.totalSupply()).to.equal(316);
      });

      it("do not allow zero amounts", async () => {
        await tokenA.approve(dex.address, 0);
        await tokenB.approve(dex.address, 0);
        await expect(dex.createPool(0, 0, { value: 0 }))
        .to.revertedWith("Insufficiently balance");
      });
    });

    describe("existing reserves", async () => {
      it("adds liquidity", async () => {
        await tokenA.approve(dex.address, 200);
        await tokenB.approve(dex.address, 2000);
        await dex.createPool(100, 1000, { value: 100 });

        await dex.createPool(100, 1000, { value: 100 });
        const t = await dex.getReserve();
        expect(t[0].toString()).to.eql("200");
        expect(t[1].toString()).to.eql("2000");
      });

      it("mints LP tokens", async () => {
        await tokenA.approve(dex.address, 200);
        await tokenB.approve(dex.address, 2000);
        await dex.createPool(100, 1000, { value: 100 });
        await dex.createPool(100, 1000, { value: 100 });

        expect(await dex.totalSupply()).to.equal(632);
      });

      it("do not allow zero amounts", async () => {
        await tokenA.approve(dex.address, 0);
        await tokenB.approve(dex.address, 0);
        await expect(dex.createPool(0, 0, { value: 0 }))
        .to.revertedWith("Insufficiently balance");
      });
    });
  });
  
  describe("Remove Liquidity", async () => {
    beforeEach(async () => {
      await tokenA.approve(dex.address, 200);
      await tokenB.approve(dex.address, 2000);
      await dex.createPool(200, 2000, { value: 100 });
      expect(await dex.totalSupply()).to.equal(632);
    });

    it("remove some liquidity", async () => {
      const userBalanceTokenABefore = await tokenA.balanceOf(owner.address);
      const userBalanceTokenBBefore = await tokenB.balanceOf(owner.address);
      await dex.withdraw(100);

      const userBalanceTokenAAfter = await tokenA.balanceOf(owner.address);
      const userBalanceTokenBAfter = await tokenB.balanceOf(owner.address);
   
      
      expect(userBalanceTokenAAfter.sub(userBalanceTokenABefore)).to.equal(31);
      expect(userBalanceTokenBAfter.sub(userBalanceTokenBBefore)).to.equal(316);
      expect(await dex.totalSupply()).to.equal(532);
    });

    it("remove all liquidity", async () => {
      const userBalanceTokenABefore = await tokenA.balanceOf(owner.address);
      const userBalanceTokenBBefore = await tokenB.balanceOf(owner.address);
      await dex.withdraw(632);

      const userBalanceTokenAAfter = await tokenA.balanceOf(owner.address);
      const userBalanceTokenBAfter = await tokenB.balanceOf(owner.address);
   
      
      expect(userBalanceTokenAAfter.sub(userBalanceTokenABefore)).to.equal(200);
      expect(userBalanceTokenBAfter.sub(userBalanceTokenBBefore)).to.equal(2000);
      expect(await dex.totalSupply()).to.equal(0);
    });
  });

  // describe("Swap", async () => {
  //   beforeEach(async ()=>{
  //     await tokenA.approve(dex.address, 100);
  //     await tokenB.approve(dex.address, 1000);
  //     await dex.createPool(100, 1000, { value: 100 });
  //     expect(await dex.totalSupply()).to.equal(316);
  //   });

  //   it("swap tokenA to tokenB",async () => {
  //     const userBalanceATokenBefore = await tokenA.balanceOf(owner.address);
  //     const userBalanceBTokenBefore = await tokenB.balanceOf(owner.address);
      
  //     tokenA.approve(dex.address, 1);
  //     /// tokenA 1 -> 10 tokenB
  //     await dex.swap(1);

  //     const userBalanceATokenAfter = await tokenA.balanceOf(owner.address);
  //     const userBalanceBTokenAfter = await tokenB.balanceOf(owner.address);
   
  //     expect(userBalanceBTokenAfter.sub(userBalanceBTokenBefore)).to.equal(9);
  //     expect(userBalanceATokenAfter.sub(userBalanceATokenBefore)).to.equal(-1);
       
  //   });

  //   it("swap tokenB to tokenA",async () => {
  //     const userBalanceATokenBefore = await tokenA.balanceOf(owner.address);
  //     const userBalanceBTokenBefore = await tokenB.balanceOf(owner.address);
      
  //     tokenA.approve(dex.address, 1);
  //     /// tokenB 11 -> 1 tokenB
  //     await dex.swap(0, 11);

  //     const userBalanceATokenAfter = await tokenA.balanceOf(owner.address);
  //     const userBalanceBTokenAfter = await tokenB.balanceOf(owner.address);
   
  //     expect(userBalanceATokenAfter.sub(userBalanceATokenBefore)).to.equal(1);
  //     expect(userBalanceBTokenAfter.sub(userBalanceBTokenBefore)).to.equal(-11);
       
  //   });
  // });
});
