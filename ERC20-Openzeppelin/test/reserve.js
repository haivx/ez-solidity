const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Reserve", function () {
  let [admin, receiver, seller, buyer] = [];
  let gold;
  let reserve;
  let address0 = "0x0000000000000000000000000000000000000000";
  let reserveBalance = ethers.utils.parseEther("1000");
  let oneWeek = 86400 * 7;
  beforeEach(async () => {
    [admin, receiver, seller, buyer] = await ethers.getSigners();
    const Gold = await ethers.getContractFactory("Gold");
    gold = await Gold.deploy();
    await gold.deployed();
    const Reserve = await ethers.getContractFactory("Reserve");
    reserve = await Reserve.deploy(gold.address);
  });

  describe("withdrawTo", function () {
    beforeEach(async () => {
      await gold.transfer(reserve.address, reserveBalance);
    });

    it("should revert if not owner", async function () {
      await expect(
        reserve.connect(receiver).withDrawTo(receiver.address, reserveBalance)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
    it("should revert if not exceed unlock time", async () => {
      await expect(
        reserve.withDrawTo(receiver.address, reserveBalance)
      ).to.be.revertedWith("Reserve: Can not trade");
    });
    it("should revert if to is addresss 0", async () => {
      await network.provider.send("evm_increaseTime", [oneWeek * 24]);

      await expect(
        reserve.withDrawTo(address0, reserveBalance)
      ).to.be.revertedWith("Reserve: transfer to zero address");
    });
    it("should revert if exceed contract balance", async function () {
      await network.provider.send("evm_increaseTime", [oneWeek * 24]);
      await expect(
        reserve.withDrawTo(receiver.address, reserveBalance + 1)
      ).to.be.revertedWith("Reserve: exceeds contract balance");
    });
    it("should withdraw correctly", async function () {
      await network.provider.send("evm_increaseTime", [oneWeek * 24]);
      expect(await gold.balanceOf(reserve.address)).to.be.equal(reserveBalance);
      await reserve.withDrawTo(receiver.address, reserveBalance);
      expect(await gold.balanceOf(reserve.address)).to.be.equal(0);
    });
  });

  describe("Combined with contract marketplace", function () {
    it("should withDraw correctly with fee from marketplace", async function () {
      let defaultFeeRate = 10;
      let defaultFeeDecimal = 0;
      let feeRecipientAddress = reserve.address;
      let defaultPrice = ethers.utils.parseEther("100");
      let defaultBalance = ethers.utils.parseEther("10000");
      const Petty = await ethers.getContractFactory("Petty");
      petty = await Petty.deploy();
      await petty.deployed();
    
      const Marketplace = await ethers.getContractFactory("Marketplace");
      marketPlace = await Marketplace.deploy(
        petty.address,
        defaultFeeDecimal,
        defaultFeeRate,
        feeRecipientAddress
      );
      await marketPlace.deployed();
      await gold.transfer(buyer.address, defaultBalance);

      await marketPlace.addPaymentToken(gold.address);
      await petty.mint(seller.address);
      await petty.connect(seller).setApprovalForAll(marketPlace.address, true);
      await marketPlace.connect(seller).addOrder(1, gold.address, defaultPrice);
      await gold.connect(buyer).approve(marketPlace.address, defaultPrice);
      await marketPlace.connect(buyer).executeOrder(1);

      const reserveBalanceFee = defaultPrice.mul(10).div(100);
      await network.provider.send("evm_increaseTime", [oneWeek * 24]);
      expect(await gold.balanceOf(reserve.address)).to.be.equal(
        reserveBalanceFee
      );
      await reserve.withDrawTo(receiver.address, reserveBalanceFee);
      expect(await gold.balanceOf(reserve.address)).to.be.equal(0);
    });
  });
});
