// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

// AKXG is the governance token
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../security/Roles.sol";
import "./PresaleExchange.sol";

contract AKX is Initializable, UUPSUpgradeable, Roles, ERC20Upgradeable, ERC20PermitUpgradeable {
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




	function initialize(address account, string memory name_, string memory symbol_, uint8  decimals_, uint256 supply_) initializer public {
		require(_initialized == false, "already initialized");
		__UUPSUpgradeable_init();
		__Roles_init(msg.sender);
		__ERC20_init(_name, symbol_);
		__ERC20Permit_init(_name);
		initializeAKX(account);

	}

	function _authorizeUpgrade(address newImplementation) internal virtual override onlyRole(SUPERADMIN_ROLE) {}


	fallback () external payable {}

	function isPresale(uint trustedTime, uint presaleStart) public pure returns(bool) {
		return trustedTime >= presaleStart;
	}

	function initializeAndStartPresale(address presaleExchange) public onlyRole(SUPERADMIN_ROLE) {
		_presaleExchange = PresaleExchange(presaleExchange);
		_presaleExchange.allowBuying();
	}

	function initializeAKX(address account) public onlyInitializing {
		require(_initialized == false, "contract already initialized");
		available = _totalSupply / 300;
		_mint(account, available);
		_initialized = true;
		emit Transfer(address(0), account, available);

	}


	function _afterTokenTransfer(address from, address to, uint256 amount)
	internal
	override(ERC20Upgradeable)
	{
		super._afterTokenTransfer(from, to, amount);
	}

	function _mint(address to, uint256 amount)
	internal
	override(ERC20Upgradeable)
	{
		super._mint(to, amount);
	}

	function _burn(address account, uint256 amount)
	internal
	override(ERC20Upgradeable)
	{
		super._burn(account, amount);
	}

	receive () external payable {}



}