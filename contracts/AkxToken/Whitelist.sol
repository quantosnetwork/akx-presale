// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;


import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface WhitelistInterface {
	event NewUserCreated(address indexed _user, uint blockNumber);
	event UserWhitelisted(address indexed _user, uint blockNumber);
}

contract Whitelist is WhitelistInterface, Ownable {

	using Counters for Counters.Counter;

	struct User {
		address payable _beneficiary;
		uint createdAtBlockNumber;
		string emailAddress;
		string referral;
		bool notificationsEnabled;
		bool isFounder;
	}

	Counters.Counter internal _userCount;

	User[] private _users;



	mapping(uint => User) private _whitelist;
	mapping(address => uint) private _addressToUid;
	mapping (address => bool) private _isWhitelisted;

	uint256 internal _init;

	constructor()  {
		_users.push();
		_init = 1;
	}


	function addMeToWhitelist(address myAddress, string memory email, string memory referral) public isNotWhitelisted(msg.sender) {
		_createWhitelistUser(myAddress, email, referral);
		uint uid = _getUid(myAddress);
		User memory _user = _users[uid];
		_addUserToWhitelist(uid, _user);
	}

	function checkIfIamWhitelisted(address myAddress) public view returns(bool) {
		require(_isWhitelisted[myAddress] == true, "not whitelisted");
		return true;
	}

	function getMyInfo() public view  onlyWhitelisted(msg.sender) returns(User memory _user)  {
		return _getUserByAddress(msg.sender);
	}

	function _createWhitelistUser(address beneficiary, string memory email, string memory referral) private  {
		bool notifs = true;

		require(beneficiary != address(0), "cannot create a user for zero address");
		User memory u = User(payable(address(beneficiary)), block.number, email, referral, notifs, false);
		uint uid = _userCount.current();
		_users[uid] = u;
		_addressToUid[beneficiary] = uid;
		_userCount.increment();
		emit NewUserCreated(beneficiary, block.number);

	}

	function _addUserToWhitelist(uint uid, User memory _user) private isNotWhitelisted(_user._beneficiary) {

		_whitelist[uid] = _user;
		_isWhitelisted[_user._beneficiary] = true;
		emit UserWhitelisted(payable(address(_user._beneficiary)), block.number);
	}

	function _getUserByAddress(address _sender) private view returns(User memory) {
		return _users[_getUid(_sender)];
	}

	function _getUid(address _sender) private view returns(uint) {
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