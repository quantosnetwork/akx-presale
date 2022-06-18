// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract PriceAggregator  {


	using SafeMath for uint;
	using SafeCast for int256;

/// will need to change the addresses for mainnet
address public immutable LINK_TOKEN=0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
address public immutable MATIC_TO_USD=0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada;
address public immutable ETH_TO_USD=0x0715A7794a1dc8e42615F059dD6e406A6594651A;
address public immutable BTC_TO_USD=0x007A22900a3B98143368Bd5906f8E17e9867581b;

AggregatorV3Interface internal MaticToUsd;
	AggregatorV3Interface internal EthToUsd;
	AggregatorV3Interface internal BtcToUsd;

	constructor() {
		//setChainlinkToken(LINK_TOKEN);
		//setChainlinkOracle(MATIC_TO_USD);
		MaticToUsd = AggregatorV3Interface(MATIC_TO_USD);
		EthToUsd = AggregatorV3Interface(ETH_TO_USD);
		BtcToUsd = AggregatorV3Interface(BTC_TO_USD);
	}

	function getMaticUsd() public view returns(int) {
		(
		, int price, , ,
		) = MaticToUsd.latestRoundData();
		return price;
	}

	function getEthUsd() public view returns(uint) {
		(
		, int price, , ,
		) = EthToUsd.latestRoundData();

		return price.toUint256();
	}

	function convertMatic(uint tokenPriceUSD) public view returns(uint) {
		uint MaticUSD = uint256(getMaticUsd());
		return MaticUSD.div(tokenPriceUSD);
	}

	function qtyToUSD(uint qty) public view returns(uint) {
		uint MaticUSD = uint256(getMaticUsd());

		return qty.mul(MaticUSD).div(10);
	}

	function qtyToMatics(uint qty) public view returns(uint) {
		uint price = uint256(getMaticUsd()) / 10 ** 18;

		return price.mul(qty);

	}

}