// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "../security/Roles.sol";

contract AkxFeesRelayer is Initializable, Roles {
	using AddressUpgradeable for address;
	using SafeERC20Upgradeable for IERC20Upgradeable;
	using CountersUpgradeable for CountersUpgradeable.Counter;



CountersUpgradeable.Counter _feeIndex;

	address public feeSafe;

	uint256 internal _receivedFees;
	uint256 internal _pendingTransfer;
	uint256 internal _doneTransfering;

	uint256[] private _fees;
	address public _operator;

	event FeeReceived(address indexed _from, uint256 amount);
	event FeesSentToSafe(address indexed _from, address indexed _to, uint256 _amount);
	event ExternalFeesReceived(address indexed _from, uint256 amount);


	function initialize(address _safe, uint256 _defaultFeeRate) public initializer {

		require(_defaultFeeRate <= 1e18, "!Interest fee");
		__Roles_init(msg.sender);
		defaultFeeRate = _defaultFeeRate;
		_receivedFees = 0;
		_pendingTransfer = 0;
		_doneTransfering = 0;
		feeSafe = _safe;

	}

	uint256 public defaultFeeRate;

	function _setDefaultFeeRate(uint256 _defaultFeeRate)
	external
	onlyRole(SUPERADMIN_ROLE)
	{
		require(_defaultFeeRate <= 1e18, "!Interest fee");
		defaultFeeRate = _defaultFeeRate;
	}

	function _addReceivedFees(address _sender, uint256 amount) internal {
		require(_sender.isContract(), "only contract can send fees");
		_fees[_feeIndex.current()] = amount;
		_feeIndex.increment();
		emit FeeReceived(_sender, amount);
	}

	function _transferFeesToFeeSafe(uint256 _amount) internal {
		payable(address(feeSafe)).transfer(_amount);
		emit FeesSentToSafe(address(this), feeSafe, _amount);
	}

	/**
     * @dev Receives ETH / Matic fees.
     */
	receive() external payable {
		emit ExternalFeesReceived(msg.sender, msg.value);
	}

	fallback() external {}
}