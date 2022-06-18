import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther} from 'ethers/lib/utils';
// @ts-ignore
import {upgrades, ethers} from "hardhat";



const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
// code here
// @ts-ignore
const {deployments, getNamedAccounts} = hre;
const {deploy} = deployments;
const deployer = await ethers.getSigners();

const Oracle = await ethers.getContractFactory("PriceAggregator");
const oracle = await Oracle.deploy();

console.log(`chainlink pricefeed oracle deployed at ${oracle.address}`);
//await oracle.deployTransaction.wait(5);
//await hre.run("verify:verify", {address: oracle.address});






};
export default func;
func.tags = ['all','oracle',"chainlink"];