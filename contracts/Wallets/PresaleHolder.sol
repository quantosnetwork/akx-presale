// SPDX-License-Identifier: MIT
pragma solidity >0.4.23 <0.9.0;

import "./VestingWallet.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../AkxToken/Akx.sol";
import "hardhat/console.sol";


contract PresaleHolder is Initializable, VestingWallet {

	address private deployer;

	address private beneficiary;

	bool private setup = true;


	constructor() {
		deployer = msg.sender;
	}

	function initialize(address _beneficiary, address _token) public initializer {
		beneficiary = _beneficiary;
		this.initializeVesting(_token, _beneficiary);

	}

	function SetupHolder(address _transferFrom, address _recipient, uint256 _amount, uint16 _vestingDurationDays, uint16 _vestingCliffDays,  address _token,address _wallet) public {

		addTokenGrant(_transferFrom, _recipient, _amount, _vestingDurationDays, _vestingCliffDays, _token, _wallet);

	}

}


contract PresaleHolderFactory is Ownable {

	using Counters for Counters.Counter;
	using Clones for address;

	address public master;

	event PresaleHolderCreated(address newHolder);

	Counters.Counter _count;


	constructor(address _master) public {
			master = _master;
	}

	function getHolderAddress(bytes32 salt) public view returns(address) {
		require(master != address(0), "master must be set");
		return master.predictDeterministicAddress(salt);
	}

	function createPresaleHolder(bytes32 salt) public payable onlyOwner {
		master.cloneDeterministic(salt);
	}

	function getWalletAddress() public view returns(address) {
		bytes32 salt = keccak256(abi.encodePacked(_count.current()));
		return getHolderAddress(salt);
	}




	function _newHolder() public onlyOwner  {
		bytes32 salt = keccak256(abi.encodePacked(_count.current()));
		_count.increment();
		createPresaleHolder(salt);

	}



}

contract PresaleHoldersDirectory is PresaleHolderFactory {


	address[] private _holderWallets;
	/// @dev _sender address => _holderWallet address
	mapping(address => address) private _holdersToWalletAddress;
	/// @dev uint phase => _sender address => _holderWallet address
	mapping(uint => mapping(address => address)) private _phaseToHoldersToWallets;
	/// @dev uint phase => _sender address => isSender bool
	mapping(uint => mapping(address => bool)) private _isPresaleHolder;

	mapping(address => uint) private _indexes;
	constructor(address _walletImpl) PresaleHolderFactory(_walletImpl) {

	}

	function addNewHolder(uint _phase, address _for) public onlyOwner  {
		 _newHolder();
			}

	function getMyPresaleWallet(uint phase) external view returns(address) {
		require(msg.sender != address(0), "no zero address");
		require(_isPresaleHolder[phase][msg.sender] == true, "you do not have a presale wallet... yet");
		return _holdersToWalletAddress[msg.sender];
	}



}



