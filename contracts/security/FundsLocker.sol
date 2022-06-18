// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Roles.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";


interface FundsLockerInterface is IERC165Upgradeable {
	event FundsLocked(address indexed _from, address indexed _lockedAccount, uint blockNum);
	event FundsUnlocked(address indexed _from, address indexed _lockedAccount, uint blockNum);

	function lockFunds(address) external;
	function unlockFunds(address) external;
	function timeLock(address, address, uint) external;
	function lockOnlyAmount(address, address, uint) external;
	function lockOnlyAmount(address, address, uint, uint) external;


}


abstract contract FundsLockerManager is Roles {
	bytes32 internal constant LOCK_STORAGE_SLOT = keccak256("funds_locker_manager.locker.address");

	function setLocker(address locker) external onlyRole(TREASURY_ROLE) {
		if(locker != address(0)) {
			require(FundsLockerInterface(locker).supportsInterface(type(FundsLockerInterface).interfaceId), "system error interface id");
			bytes32 slot = LOCK_STORAGE_SLOT;
			assembly {
				sstore(slot, locker)
			}

		}
	}

	function getLocker()  internal view virtual returns(address locker) {
		bytes32 slot = LOCK_STORAGE_SLOT;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			locker := sload(slot)
		}

	}

}

abstract contract FundsLocker is FundsLockerInterface, Roles {
	bytes32 internal constant LOCK_STORAGE_SLOT = keccak256("funds_locker.locker.struct");
	mapping(address => uint256) internal lockedAmount;
	mapping(address => uint256) internal unlockedAmount;
	mapping(address => uint) internal willUnlockAt;
	struct Locker {
		bool active;
	}

	// solhint-disable-next-line payable-fallback
	fallback() external {
		// We don't revert on fallback to avoid issues in case of a Safe upgrade
		// E.g. The expected check method might change and then the Safe would be locked.
	}

	function getLocker() internal view virtual  returns (Locker storage locker) {
		bytes32 slot = LOCK_STORAGE_SLOT;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			locker.slot := slot
		}
	}

	function lockFunds(address _wal) public onlyRole(TREASURY_ROLE){
		Locker storage locker = getLocker();
		require(!locker.active, "funds are locked");
		locker.active = true;
		emit FundsLocked(msg.sender, _wal, block.number);
	}

	function unlockFunds(address _wal) public onlyRole(TREASURY_ROLE) {
		Locker storage locker = getLocker();
		require(locker.active, "funds are not locked");
		getLocker().active = false;
		emit FundsUnlocked(msg.sender, _wal, block.number);
	}

	function _timeLock(address _wal, address _token, uint _duration) internal {
		lockFunds(_wal);
		willUnlockAt[_wal] = block.timestamp + _duration;
		lockedAmount[_wal] = IERC20Upgradeable(_token).balanceOf(_wal); // all funds are locked
		unlockedAmount[_wal] = 0;
	}

	function timeLock(address _wal, address _token, uint _duration) public  override onlyRole(TREASURY_ROLE) {
		 _timeLock(_wal, _token, _duration);
	}

	function _lockOnlyAmount(address _wal, address _token, uint amount) internal {
		lockFunds(_wal);
		willUnlockAt[_wal] = 0;
		lockedAmount[_wal] = amount;
		if(IERC20Upgradeable(_token).balanceOf(_wal) > amount) {
		unlockedAmount[_wal] = IERC20Upgradeable(_token).balanceOf(_wal) - amount;
		} else {
			unlockedAmount[_wal] = 0;
		}
	}

	function _lockOnlyAmountWithTimeLock(address _wal, address _token, uint amount, uint duration) internal {
		lockFunds(_wal);
		willUnlockAt[_wal] = block.timestamp + duration;
		lockedAmount[_wal] = amount;
		if(IERC20Upgradeable(_token).balanceOf(_wal) > amount) {
			unlockedAmount[_wal] = IERC20Upgradeable(_token).balanceOf(_wal) - amount;
		} else {
			unlockedAmount[_wal] = 0;
		}
	}

	function lockOnlyAmount(address _wal, address _token, uint amount) public onlyRole(TREASURY_ROLE) {
		_lockOnlyAmount(_wal, _token, amount);
	}

	function lockOnlyAmount(address _wal, address _token, uint amount, uint duration) public onlyRole(TREASURY_ROLE) {
		_lockOnlyAmountWithTimeLock(_wal, _token, amount, duration);
	}

	function checkLock(address _wal) public returns(uint256, uint256, uint) {
		return (lockedAmount[_wal], unlockedAmount[_wal], willUnlockAt[_wal]);
	}

	function getUnlockedBalance(address _wal)public returns(uint256) {
		return unlockedAmount[_wal];
	}

	function getLockedAndUnlockedBalance(address _wal) public returns(uint256) {
		return unlockedAmount[_wal] + lockedAmount[_wal];
	}

	function whenFundsUnlocks(address _wal) public returns(uint256) {
		return willUnlockAt[_wal];
	}

	function isUnlocked(address _wal) public returns(bool can) {
		can = block.timestamp > whenFundsUnlocks(_wal);
	}

	function _unlockFunds(address _wal) internal {
		require(isUnlocked(_wal) == true, "cannot unlock funds yet");
		uint256 l = lockedAmount[_wal];
		uint256 u = unlockedAmount[_wal];
		u += l;
		l = 0;
		unlockFunds(_wal);

	}



	function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, IERC165Upgradeable) returns (bool) {
		return
		interfaceId == type(FundsLockerInterface).interfaceId || // 0xe6d7a83a
		interfaceId == type(IERC165Upgradeable).interfaceId; // 0x01ffc9a7s
	}





}
