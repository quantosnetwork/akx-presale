import {ethers} from "hardhat";
import {parseEther, solidityKeccak256} from "ethers/lib/utils";

const { expect } = require('chai');
import ABI from "../data/abi/PresaleHolder.json";

// Start test block
describe('Presale Holder wallet', function () {
    before(async function () {
        this.Wallet = await ethers.getContractFactory("PresaleHolder");
        this.FACTORY = await ethers.getContractFactory("PresaleHoldersDirectory");

        this.signers = await ethers.getSigners();

      this.AKX = await ethers.getContractFactory("AKX");

    });

    beforeEach(async function () {
        this.signer = this.signers[0].address;
        const tokenConfig = {
            account: this.signer,
            name: 'AKX Lab',
            symbol: 'LABZ',
            decimal: 18,
            supply: parseEther("100000000000")
        };
        this.token = await this.AKX.deploy( tokenConfig.account,
            tokenConfig.name,
            tokenConfig.symbol,
            tokenConfig.decimal,
            tokenConfig.supply);
       await this.token.deployed();

        this.wallet = await this.Wallet.deploy();

        await this.wallet.deployed();

        this.implementation = this.wallet.address;
        this.directory = await this.FACTORY.deploy(this.implementation);
        await this.directory.deployed();





    });

    // Test case
    it('should have an address', async function () {
        const addr = await this.directory.getWalletAddress();
        console.log(addr);
        expect(addr).to.exist;

    });

    it('should add a new grant and validate amount', async function () {
        const addr = await this.directory.getWalletAddress();
        const tx = await this.directory.addNewHolder(1, this.signers[1].address);
        await tx.wait();

        const newWallet = await this.Wallet.attach(addr);

      await this.token.grantRole(ethers.utils.solidityKeccak256(["string"],["MINTER_ROLE"]), newWallet.address);


        await newWallet.SetupHolder(this.signer, this.signers[1].address, parseEther("100"), 1, 0,  this.token.address, newWallet.address);
       const amount =  await newWallet.getGrantAmount(this.signers[1].address);
       await this.token.revokeRole(ethers.utils.solidityKeccak256(["string"],["MINTER_ROLE"]), newWallet.address);
       expect(amount).to.equal(parseEther("100"));


    });


});