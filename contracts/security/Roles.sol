// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

abstract contract Roles is AccessControlEnumerable {

	bytes32 public constant PRESALE_OPERATOR = keccak256("PRESALE_OPERATOR");
	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	bytes32 public constant SUPERADMIN_ROLE = keccak256("SUPERADMIN_ROLE");
	bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");
	bytes32 public constant CEO_ROLE = keccak256("CEO_ROLE");
	bytes32 public constant CTO_ROLE = keccak256("CFO_ROLE");
	bytes32 public constant CFO_ROLE = keccak256("CTO_ROLE");
	bytes32 public constant FEE_OPERATOR_ROLE = keccak256("FEE_OPERATOR_ROLE");
	bytes32 public constant HOLDER_ROLE = keccak256("HOLDER_ROLE");



	constructor(address _initial) {

		/// @notice we set all the roles to the deployer address when initializing
		_setupRole(PRESALE_OPERATOR, _initial);
		_setupRole(MINTER_ROLE, _initial);
		_setupRole(SUPERADMIN_ROLE, _initial);
		_setupRole(TREASURY_ROLE, _initial);
		_setupRole(CEO_ROLE, _initial);
		_setupRole(CTO_ROLE, _initial);
		_setupRole(CFO_ROLE, _initial);
		_setupRole(FEE_OPERATOR_ROLE, _initial);
	}

	function changeRole(address _subject, string memory role, string memory roleToRevoke) onlyRole(SUPERADMIN_ROLE) public {
		require(hasRole(keccak256(abi.encode(roleToRevoke)), _subject), "cannot revoke non existant role");
		_revokeRole(keccak256(abi.encode(roleToRevoke)), _subject);
		require(!hasRole(keccak256(abi.encode(role)), _subject), "sender already has this role");
		_grantRole(keccak256(abi.encode(role)), _subject);

	}

	function giveRole(address _subject, string memory role) onlyRole(SUPERADMIN_ROLE) public {
		require(!hasRole(keccak256(abi.encode(role)), _subject), "sender already has this role");
		_grantRole(keccak256(abi.encode(role)), _subject);
	}

	modifier OnlySuperAdmin(address _sender) {
		require(hasRole(SUPERADMIN_ROLE, _sender), "ACCESS UNAUTHORIZED");
		_;
	}

	modifier OnlyMinter(address _sender) {
		require(hasRole(MINTER_ROLE,_sender), "ACCESS UNAUTHORIZED");
		_;
	}

	modifier OnlyPresaleOperator(address _sender) {
		require(hasRole(PRESALE_OPERATOR, _sender), "ACCESS UNAUTHORIZED");
		_;
	}

	modifier OnlyTreasurer(address _sender) {
		require(hasRole(TREASURY_ROLE, _sender), "ACCESS UNAUTHORIZED");
		_;
	}

	modifier OnlyCLevel(address _sender) {
		require(hasRole(CEO_ROLE, _sender) || hasRole(CTO_ROLE, _sender) || hasRole(CFO_ROLE, _sender), "ACCESS UNAUTHORIZED");
		_;
	}

	modifier OnlyHolder(address _sender) {
		require(hasRole(HOLDER_ROLE, _sender), "ACCESS UNAUTHORIZED");
		_;
	}

	modifier OnlyFeeOperator(address _sender) {
		require(hasRole(FEE_OPERATOR_ROLE, _sender), "ACCESS UNAUTHORIZED");
		_;
	}



}