// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

// AKXG is the governance token
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "../security/Roles.sol";
import "./PresaleExchange.sol";
import "hardhat/console.sol";

contract AKX is Roles, ERC20, ERC20Permit {
	string public  _name;
	string public _symbol;
	uint8 public _decimals;
	uint256 public  _totalSupply; /// 300000000000e18; // 300 billions AKX tokens

	PresaleExchange private _presaleExchange;

	uint256 public available;

	bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
	bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

	uint256 public constant _proposalThreshold = 10000e18; // 10,000 tokens needed to submit a proposal (0.1%)

	bool internal _initialized;




	constructor(address account, string memory name_, string memory symbol_, uint8  decimals_, uint256 supply_) Roles(msg.sender) ERC20(name_, symbol_) ERC20Permit(name_) {

		_name = name_;
		_symbol = symbol_;
		_decimals = decimals_;
		initializeAKX(account, supply_);
	}

	function grantToHolderWallet(address _holder) public OnlySuperAdmin(msg.sender) {
		giveRole(_holder,MINTER_ROLE);
	}



	function isPresale(uint trustedTime, uint presaleStart) public pure returns(bool) {
		return trustedTime >= presaleStart;
	}

	function initializeAndStartPresale(address presaleExchange) public OnlySuperAdmin(msg.sender) {
		_presaleExchange = PresaleExchange(presaleExchange);
		_presaleExchange.allowBuying();
	}

	function initializeAKX(address account, uint _totalSupply) public {

		available = _totalSupply;
		mint(msg.sender, available);
		_initialized = true;


	}


	function _afterTokenTransfer(address from, address to, uint256 amount)
	internal
	override(ERC20)
	{
		super._afterTokenTransfer(from, to, amount);
	}

	function _mint(address to, uint256 amount)
	internal
	override(ERC20)
	{
		super._mint(to, amount);
	}

	function mint(address to, uint256 amount) public  OnlyMinter(msg.sender) {
		_mint(to, amount);
	}

	function _burn(address account, uint256 amount)
	internal
	override(ERC20)
	{
		super._burn(account, amount);
	}

	receive () external payable {}



}