// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;



import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./PriceAggregator.sol";

import "../security/Roles.sol";

contract PresaleExchange is Initializable, Roles {

	using SafeERC20Upgradeable for IERC20Upgradeable;

	address private _whitelistContract;
	address private _presaleContract;
	address private _reserveAkx;
	address private _reserveMatic;
	uint public tokenPrice;

	bool internal _canBuy;
	bool internal _canSell;
	bool internal _canSwap;

	uint256 public totalPresaleSupply;

	address private _priceAggregator;

	uint private _priceMultiplicator; // price for 1 AKX

	function initialize(address  contracts, address _priceFeedAggregator, uint _supply, uint multiplicator) initializer public {
		_priceAggregator = _priceFeedAggregator;
		//_priceMultiplicator =  9592761;
		_priceMultiplicator = multiplicator;
		_whitelistContract = contracts;
		//_presaleContract = contracts[1];
		//_reserveMatic = contracts[2];
		_canBuy = false;
		_canSell = false;
		_canSwap = false;
		totalPresaleSupply = _supply;
		tokenPrice = convertQtyToMatics(1);

	}


	function buy(address _token, uint qty) payable public onlyCanBuy {
		uint256 _amountToBuy = convertQtyToMatics(qty);
		require(msg.sender != address(0), "no zero address");
		require(_amountToBuy > 0, "you need to send some value");
		IERC20Upgradeable(_token).safeTransfer(msg.sender, _amountToBuy * 10 ** 18);
	}

	function sell(address _token, uint qty) public onlyCanSell {
		uint256 amountToSell = qty;
		require(amountToSell > 0, "you need to send some value");
		require(amountToSell <= IERC20Upgradeable(_token).balanceOf(msg.sender), "not enough reserve");
		IERC20Upgradeable(_token).safeTransferFrom(msg.sender, payable(address(_token)), qty);
	}

	function allowSelling() public onlyRole(SUPERADMIN_ROLE) {
		require(!_canSell, "selling already enabled");
		_canSell = true;
	}

	function allowBuying() public onlyRole(SUPERADMIN_ROLE) {
		require(!_canBuy, "buying already enabled");
		_canBuy = true;
	}

	function swap() payable public {}


	modifier checkBalances(uint[2] memory _balances) {
		require(address(this).balance >= _balances[0] + _balances[1], "not enough balance");
		_;
	}

	modifier onlyCanBuy() {
		require(_canBuy == true, "cannot buy yet");
		_;
	}

	modifier onlyCanSell() {
		require(_canSell == true, "cannot sell yet");
		_;
	}

	function convertUsdToMaticPrice(uint priceUSD)  public view returns (uint) {
		return PriceAggregator(_priceAggregator).convertMatic(priceUSD);
	}

	function convertQtyToMatics(uint qty) public view returns (uint) {
		return PriceAggregator(_priceAggregator).qtyToMatics(qty);
	}


}