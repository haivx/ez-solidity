const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Crud", function () {
  let crud;
  beforeEach(async () => {
    const Greeter = await ethers.getContractFactory("Crud");
    crud = await Greeter.deploy();
  });

  it("Should return the new greeting when creating new one", async function () {
    await crud.deployed();
    crud.create("Xuan Hai");
    const player = await crud.read(1);
    console.log(player);
    expect(player[0]).to.equal("1");
    expect(player[1]).to.equal("Xuan Hai");
  });
});
