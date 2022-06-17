// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

// AKXG is the governance token
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract AKXDao is ERC20, ERC20Permit, ERC20Votes {
	string public constant _name = "AKX DAO";
	string public constant _symbol = "DAOX";
	uint8 public constant _decimals = 18;
	uint256 public constant _totalSupply = 300000000e18; // 300 million AKX tokens


	bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
	bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

	uint256 public constant _proposalTreshold = 10000e18; // 10,000 tokens needed to submit a proposal (0.1%)



	bool internal _initialized = false;

	/**
	 * @notice Construct a new AKXG token
     * @param account The initial account to grant all the tokens
     */
	constructor(address account) ERC20(_name, _symbol) ERC20Permit(_name) {
		initializeAKXG(account);

	}

	function initializeAKXG(address account) public {
		require(_initialized == false, "contract already initialized");
		_mint(account, _totalSupply);
		emit Transfer(address(0), account, _totalSupply);
		_initialized = true;

	}


	function _afterTokenTransfer(address from, address to, uint256 amount)
	internal
	override(ERC20, ERC20Votes)
	{
		super._afterTokenTransfer(from, to, amount);
	}

	function _mint(address to, uint256 amount)
	internal
	override(ERC20, ERC20Votes)
	{
		super._mint(to, amount);
	}

	function _burn(address account, uint256 amount)
	internal
	override(ERC20, ERC20Votes)
	{
		super._burn(account, amount);
	}


}