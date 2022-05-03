const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

const getBalance = ethers.provider.getBalance;

use(solidity);

describe("My DEX", function () {
  let owner;
  let dex;
  let user;
  let tokenA;
  let tokenB;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("Token");
    tokenA = await Token.deploy("TokenA", "TKA", 10000);
    tokenB = await Token.deploy("TokenB", "TKB", 100000);
    await tokenA.deployed();
    await tokenB.deployed();

    const Dex = await ethers.getContractFactory("Dex");
    dex = await Dex.deploy(tokenA.address, tokenB.address);
    await dex.deployed();
  });


});
