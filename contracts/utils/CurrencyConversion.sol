// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./Math.sol";

interface CurrencyConversionInterface {
	function _calculateRate(uint256 base, uint256 convertTo) external;
}


abstract contract CurrencyConversion is CurrencyConversionInterface, AkxMath {




	address public baseCurrency;
	uint256 public res;

	function _calculateRate(uint256 base, uint256 _rate) public override {
		res = mulDiv(base, 1e4, _rate);

	}



	function getResult()  public view returns(uint256) {

		return res;
	}


}
