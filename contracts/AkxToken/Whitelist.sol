// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

interface WhitelistInterface {
	event NewUserCreated(address indexed _user, uint blockNumber);
	event UserWhitelisted(address indexed _user, uint blockNumber);
}

contract Whitelist is Initializable, WhitelistInterface {

	using CountersUpgradeable for CountersUpgradeable.Counter;

	struct User {
		address payable _beneficiary;
		uint createdAtBlockNumber;
		string emailAddress;
		string referral;
		bool notificationsEnabled;
		bool isFounder;
	}

	CountersUpgradeable.Counter internal _userCount;

	User[] internal _users;



	mapping(uint => User) internal _whitelist;
	mapping(address => uint) internal _addressToUid;
	mapping (address => bool) internal _isWhitelisted;

	uint256 internal _init;

	function initialize() initializer public {
		__Whitelist_init();
	}

	function __Whitelist_init() onlyInitializing internal {

	}

	function __Whitelist_init_unchained() onlyInitializing internal {

	}

	function addMeToWhitelist(address myAddress, string memory email, string memory referral) public isNotWhitelisted(msg.sender) {
		_createWhitelistUser(myAddress, email, referral);
		uint uid = _getUid(myAddress);
		User memory _user = _users[uid];
		_addUserToWhitelist(_user);
	}

	function checkIfIamWhitelisted(address myAddress) public returns(bool) {
		return _isWhitelisted[myAddress];
	}

	function _createWhitelistUser(address beneficiary, string memory email, string memory referral) internal {
		bool notifs = true;

		require(beneficiary != address(0), "cannot create a user for zero address");
		User memory u = User(payable(address(beneficiary)), block.number, email, referral, notifs, false);
		uint uid = _userCount.current();
		_users[uid] = u;
		_addressToUid[beneficiary] = uid;
		_userCount.increment();
		emit NewUserCreated(beneficiary, block.number);

	}

	function _addUserToWhitelist(User memory _user) internal isNotWhitelisted(_user._beneficiary) {
		uint uid = _getUid(address(_user._beneficiary));
		_whitelist[uid] = _user;
		_isWhitelisted[_user._beneficiary] = true;
		emit UserWhitelisted(payable(address(_user._beneficiary)), block.number);
	}

	function _getUserByAddress(address _sender) internal returns(User memory) {
		return _users[_getUid(_sender)];
	}

	function _getUid(address _sender) internal returns(uint) {
		uint uid = _addressToUid[_sender];
		return uid;
	}

	function _verifyUserWL(address _sender, User memory _user) internal returns(bool) {
		require(_user.createdAtBlockNumber < block.number, "invalid user block");
		require(_getUid(_user._beneficiary) > 0, "invalid uid");
		require(_sender == _user._beneficiary, "user addresses dont match");
		require(_getUid(_user._beneficiary) > _userCount.current(), "invalid uid");
		return true;
	}

	modifier isNotWhitelisted(address _sender) {
		require(_isWhitelisted[_sender] != true, "already whitelisted");
		_;
	}

	modifier onlyWhitelisted(address _sender)  {
		require(_isWhitelisted[_sender] == true, "need whitelisted");
		_;
	}

}