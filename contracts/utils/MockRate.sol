// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./CurrencyConversion.sol";
import  "@rari-capital/solmate/src/tokens/ERC20.sol";
import  "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import  "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract MockToken is ERC20, ReentrancyGuard {

	uint256 public constant pricePercent = 5 * 1e4; // 5%

	constructor() ERC20("mockToken", "mTok", 18) {}

}

contract MockBaseToken is ERC20, ReentrancyGuard {

	uint256 public constant pricePercent = 100 * 1e4; // 1:1 for testing

	constructor() ERC20("mockToken", "mTok", 18) {}

}


contract MockRate is CurrencyConversion {


	MockToken public _mtoken; // mock token
	MockBaseToken public _baseToken;

	constructor(address base, address mtok) {
		_baseToken = MockBaseToken(base);
		_mtoken = MockToken(mtok);
	}

	function calculateRateForQty(uint256 mtokQty) public  {
		_calculateRate(_baseToken.pricePercent(), _mtoken.pricePercent());
		uint256 r = getResult();
		res = r * mtokQty;

	}

}