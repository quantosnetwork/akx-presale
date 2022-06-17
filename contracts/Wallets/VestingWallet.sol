// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../security/Roles.sol";

interface IVestingWallet {
	event GrantAdded(address indexed recipient);
	event GrantTokensClaimed(address indexed recipient, uint256 amountClaimed);
	event GrantRevoked(address recipient, uint256 amountVested, uint256 amountNotVested);

}

contract VestingWallet is IVestingWallet, Initializable, Roles, ReentrancyGuard {

	using SafeMath for uint256;
	using SafeMath for uint16;
	using SafeCast for uint;
	using SafeERC20 for ERC20;

	struct Grant {
		uint256 startTime;
		uint256 amount;
		uint16 vestingDuration;
		uint16 daysClaimed;
		uint256 totalClaimed;
		address beneficiary;
	}

	ERC20 public token;
	address public tokenSafe;

	address public walletOwner;

	mapping(address => Grant) private _tokenGrants;

	function initialize(address _token, address _sender) initializer public {
		require(_token != address(0), "no zero address");
		token = ERC20(_token);
		walletOwner = _sender;
		// live token safe = 0x5dA5aE3f9E4ee7682A2b0a233E4553A21b4f0044
		tokenSafe = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // dev address need to replace before live
	}

	function addTokenGrant(address _recipient, uint256 _amount, uint16 _vestingDurationDays, uint16 _vestingCliffDays) external onlyOwner nonReentrant {
		require(_tokenGrants[_recipient].amount == 0, "Grant already exists, must revoke first.");
		require(_vestingCliffDays <= 10*365, "Cliff greater than 10 years");
		require(_vestingDurationDays <= 25*365, "Duration greater than 25 years");

		uint256 amountVestedPerDay = _amount.div(_vestingDurationDays);
		require(amountVestedPerDay > 0, "amountVestedPerDay > 0");

		// Transfer the grant tokens under the control of the vesting contract
		token.safeTransferFrom(tokenSafe, address(this), _amount);

		Grant memory grant = Grant({
		startTime: currentTime() + _vestingCliffDays * 1 days,
		amount: _amount,
		vestingDuration: _vestingDurationDays,
		daysClaimed: 0,
		totalClaimed: 0,
		beneficiary: _recipient
		});
		_tokenGrants[_recipient] = grant;
		emit GrantAdded(_recipient);
	}

	/// @notice Allows a grant recipient to claim their vested tokens. Errors if no tokens have vested
	function claimVestedTokens() external nonReentrant {
		uint16 daysVested;
		uint256 amountVested;
		(daysVested, amountVested) = calculateGrantClaim(msg.sender);
		require(amountVested > 0, "Vested is 0");

		Grant storage tokenGrant = _tokenGrants[msg.sender];
		tokenGrant.daysClaimed = uint16(tokenGrant.daysClaimed.add(daysVested));
		tokenGrant.totalClaimed = uint256(tokenGrant.totalClaimed.add(amountVested));

		require(token.transfer(tokenGrant.beneficiary, amountVested), "no tokens");
		emit GrantTokensClaimed(tokenGrant.beneficiary, amountVested);
	}

	/// @notice Terminate token grant transferring all vested tokens to the `_recipient`
	/// and returning all non-vested tokens to the contract owner
	/// Secured to the contract owner only
	/// @param _recipient address of the token grant recipient
	function revokeTokenGrant(address _recipient)
	external
	onlyOwner
	{
		Grant storage tokenGrant = _tokenGrants[_recipient];
		uint16 daysVested;
		uint256 amountVested;
		(daysVested, amountVested) = calculateGrantClaim(_recipient);

		uint256 amountNotVested = (tokenGrant.amount.sub(tokenGrant.totalClaimed)).sub(amountVested);

		require(token.transfer(owner(), amountNotVested));
		require(token.transfer(_recipient, amountVested));

		tokenGrant.startTime = 0;
		tokenGrant.amount = 0;
		tokenGrant.vestingDuration = 0;
		tokenGrant.daysClaimed = 0;
		tokenGrant.totalClaimed = 0;
		tokenGrant.beneficiary = address(0);

		emit GrantRevoked(_recipient, amountVested, amountNotVested);
	}

	modifier onlyOwner() {
		require(msg.sender == walletOwner, "access denied");
		_;
	}

	function getGrantStartTime(address _recipient) private view returns(uint256) {
		Grant storage tokenGrant = _tokenGrants[_recipient];
		return tokenGrant.startTime;
	}

	function getGrantAmount(address _recipient) public view returns(uint256) {
		Grant storage tokenGrant = _tokenGrants[_recipient];
		return tokenGrant.amount;
	}

	/// @notice Calculate the vested and unclaimed months and tokens available for `_grantId` to claim
	/// Due to rounding errors once grant duration is reached, returns the entire left grant amount
	/// Returns (0, 0) if cliff has not been reached
	function calculateGrantClaim(address _recipient) public view returns (uint16, uint256) {
		Grant storage tokenGrant = _tokenGrants[_recipient];

		require(tokenGrant.totalClaimed < tokenGrant.amount, "Grant fully claimed");

		// For grants created with a future start date, that hasn't been reached, return 0, 0
		if (currentTime() < tokenGrant.startTime) {
			return (0, 0);
		}

		// Check cliff was reached
		uint elapsedDays = currentTime().sub(tokenGrant.startTime - 1 days).div(1 days);

		// If over vesting duration, all tokens vested
		if (elapsedDays >= tokenGrant.vestingDuration) {
			uint256 remainingGrant = tokenGrant.amount.sub(tokenGrant.totalClaimed);
			return (tokenGrant.vestingDuration, remainingGrant);
		} else {
			uint16 daysVested = uint16(elapsedDays.sub(tokenGrant.daysClaimed));
			uint256 amountVestedPerDay = tokenGrant.amount.div(uint256(tokenGrant.vestingDuration));
			uint256 amountVested = uint256(daysVested.mul(amountVestedPerDay));
			return (daysVested, amountVested);
		}
	}

	function currentTime() private view returns(uint256) {
		return block.timestamp;
	}

	function fetchGrantData() public view returns(uint256){
		Grant storage tokenGrant = _tokenGrants[msg.sender];
		return tokenGrant.totalClaimed;
	}

	function owner() public view returns(address) {
		return tokenSafe;
	}


}