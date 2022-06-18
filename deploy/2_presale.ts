import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther} from 'ethers/lib/utils';
// @ts-ignore
import {upgrades, ethers} from "hardhat";



const func4: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
// code here
// @ts-ignore
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const deployer = await ethers.getSigners();


    const WL = await ethers.getContractFactory("Whitelist");
    const wl = await upgrades.deployProxy(WL, [], {initializer:"initialize"});
    await wl.deployed();

    const wlimpl = await upgrades.erc1967.getImplementationAddress(wl.address);
   await hre.run("verify:verify", {address: wlimpl});

    const PA = await ethers.getContractFactory("PriceAggregator");
    const pa = await PA.deploy();
    await pa.deployTransaction.wait(5);
   //await hre.run("verify:verify", {address: pa.address});


    const presale = await ethers.getContractFactory("PresaleExchange");
    const PEX = await upgrades.deployProxy(presale, [
        wl.address,
        pa.address,
        parseEther("10000000000"),
        9592761
    ], {initializer:"initialize"});

    await PEX.deployed();

    console.log(`Presale Exchange deployed at ${PEX.address}`);
    console.log(`Whitelist deployed at ${wl.address}`);


   const impl = await upgrades.erc1967.getImplementationAddress(PEX.address);

  await hre.run("verify:verify", {address: impl});


};
export default func4;
func4.tags = ['all','presale'];