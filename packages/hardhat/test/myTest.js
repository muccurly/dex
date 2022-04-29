const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("My DEX", function () {
  let myContract;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("DexFactory", function () {
    it("Should deploy DexFactory", async function () {
      const DexFactoryContract = await ethers.getContractFactory("DexFactory");

      myContract = await DexFactoryContract.deploy();
    });    
  });
});
