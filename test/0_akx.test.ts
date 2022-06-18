import { expect } from "chai";
import { ethers } from "hardhat";
import {parseEther} from "ethers/lib/utils";



describe("AKX Lab token", function () {


      it("Should return the right info", async function () {

        const signers = await ethers.getSigners();


        const tokenConfig = {
          account: signers[0].address,
          name: 'AKX Lab',
          symbol: 'LABZ',
          decimal: 18,
          supply: parseEther("100000000000")
        };
        const AKX = await ethers.getContractFactory("AKX");
        const token = await AKX.deploy( tokenConfig.account,
            tokenConfig.name,
            tokenConfig.symbol,
            tokenConfig.decimal,
            tokenConfig.supply);
        await token.deployed();
        expect(await token.totalSupply()).to.equal(tokenConfig.supply);


        expect(await token.name()).to.equal(tokenConfig.name);

        expect(await token.symbol()).to.equal(tokenConfig.symbol);


        expect(await token.decimals()).to.equal(tokenConfig.decimal);
      });

      it("should assign the total supply to the owner", async () => {
        const signers = await ethers.getSigners();


        const tokenConfig = {
          account: signers[0].address,
          name: 'AKX Lab',
          symbol: 'LABZ',
          decimal: 18,
          supply: parseEther("100000000000")
        };
        const AKX = await ethers.getContractFactory("AKX");
        const token = await AKX.deploy( tokenConfig.account,
            tokenConfig.name,
            tokenConfig.symbol,
            tokenConfig.decimal,
            tokenConfig.supply);
        await token.deployed();

        const ownerBalance = await token.balanceOf(signers[0].address);
        expect(await token.totalSupply()).to.equal(ownerBalance);

      })


});

describe("Transactions", function() {
  it("Should transfer tokens between accounts", async function() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const signers = await ethers.getSigners();


    const tokenConfig = {
      account: signers[0].address,
      name: 'AKX Lab',
      symbol: 'LABZ',
      decimal: 18,
      supply: parseEther("100000000000")
    };
    const AKX = await ethers.getContractFactory("AKX");
    const token = await AKX.deploy( tokenConfig.account,
        tokenConfig.name,
        tokenConfig.symbol,
        tokenConfig.decimal,
        tokenConfig.supply);
    await token.deployed();

    // Transfer 50 tokens from owner to addr1
    await token.transfer(addr1.address, 50);
    expect(await token.balanceOf(addr1.address)).to.equal(50);

    // Transfer 50 tokens from addr1 to addr2
    await token.connect(addr1).transfer(addr2.address, 50);
    expect(await token.balanceOf(addr2.address)).to.equal(50);
  });
});
