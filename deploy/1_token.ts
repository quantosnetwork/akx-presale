import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther} from 'ethers/lib/utils';
// @ts-ignore
import {upgrades, ethers} from "hardhat";



const func3: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
// code here
// @ts-ignore
const {deployments, getNamedAccounts} = hre;
const {deploy} = deployments;
const deployer = await ethers.getSigners();

const tokenConfig = {
    account: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    name: 'AKX Lab',
    symbol: 'AKX',
    decimal: 18,
    supply: parseEther("300000000000")
};

const akx = await ethers.getContractFactory("AKX");
const AKX = await upgrades.deployProxy(akx, [
    tokenConfig.account,
    tokenConfig.name,
    tokenConfig.symbol,
    tokenConfig.decimal,
    tokenConfig.supply
], {initializer:"initialize"});

await AKX.deployed();

console.log(`AKX Lab token deployed at ${AKX.address}`);

const impl = await upgrades.erc1967.getImplementationAddress(AKX.address);

await hre.run("verify:verify", {address: impl});


};
export default func3;
func3.tags = ['all','token'];