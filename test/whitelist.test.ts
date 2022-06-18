import {ethers} from "hardhat";

const { expect } = require('chai');

// Start test block
describe('Whitelist', function () {
    before(async function () {
        this.Whitelist = await ethers.getContractFactory('Whitelist');
        this.signers = await ethers.getSigners();
    });

    beforeEach(async function () {
        this.whitelist = await this.Whitelist.deploy();

        await this.whitelist.deployed();
    });

    // Test case
    it('should have an address', async function () {

        const address = this.whitelist.address;
        expect(address).to.exist;

    });

    it('should add me to the whitelist', async function () {

        await this.whitelist.addMeToWhitelist(this.signers[0].address, "info@akxlab.com", "none");
        let result = await this.whitelist.checkIfIamWhitelisted(this.signers[0].address)
        console.log(result);
        expect(result).to.be.true;
    });

    it('should return my info', async function () {
        await this.whitelist.addMeToWhitelist(this.signers[0].address, "info@akxlab.com", "none");
        let result = await this.whitelist.getMyInfo();
        console.log(result);
        expect(result.emailAddress).to.equal("info@akxlab.com");
    });
});