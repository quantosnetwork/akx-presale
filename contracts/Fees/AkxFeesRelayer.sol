// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;


import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../security/Roles.sol";

contract AkxFeesRelayer is Roles {
	using Address for address;
	using SafeERC20 for IERC20;
	using Counters for Counters.Counter;



Counters.Counter _feeIndex;

	address public feeSafe;

	uint256 internal _receivedFees;
	uint256 internal _pendingTransfer;
	uint256 internal _doneTransfering;

	uint256[] private _fees;
	address public _operator;

	event FeeReceived(address indexed _from, uint256 amount);
	event FeesSentToSafe(address indexed _from, address indexed _to, uint256 _amount);
	event ExternalFeesReceived(address indexed _from, uint256 amount);

	constructor(address _safe, uint256 _defaultFeeRate) Roles(msg.sender) {
		initialize(_safe, _defaultFeeRate);
	}

	function initialize(address _safe, uint256 _defaultFeeRate) public {

		require(_defaultFeeRate <= 1e18, "!Interest fee");
		//__Roles_init(msg.sender);
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