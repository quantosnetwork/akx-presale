// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@rari-capital/solmate/src/tokens/WETH.sol";
import "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../security/Roles.sol";
import "../security/FundsLocker.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

interface Presale {
	event PhaseStarted(uint phase, uint blocknum);
	event PhaseEnded(uint phase, uint blocknum);
	event PhasePending(uint phase, uint blockStarted);
	event PresaleInitialized(uint blocknum, address who);
	event NewHolder(address indexed holder, uint256 qty, uint256 pledged, uint blocknum);
	event PriceUpdated(address indexed who, uint256 old, uint256 _new, uint blocknum);
	event LiquidityLocked(address indexed who, address indexed wallet, uint vestingduration, uint amount);
	event PresaleToken(address indexed who, address indexed _token, uint blocknum);
	event Whitelisted(address indexed _from, address indexed _who, uint blocknum);

}


contract AkxPresale is  Initializable,PausableUpgradeable, Presale, FundsLocker {

	using SafeTransferLib for ERC20;



	mapping(address => uint256) private _holdersBalance;
	mapping(address => bool) private _isWhitelisted;
	mapping(address => bool) private _isHolder;

	address public  _gnosisVault;

	address[] private _holders;

	uint256 public presalePhase;
	address public timeLockedWallet;
	uint256 public totalHoldings;
	uint256 public remainingForPresale;
	uint256 public numHolders;
	uint256 public totalMinted;
	uint256 public totalLocked;
	uint256 public totalBurned;


	uint256 presaleTokensVestedSeconds;
	address[] public vestingWallets;

	uint256 private phase1_start_time;
	uint256 private phase1_end_time;
	uint256 private phase2_start_time;
	uint256 private phase2_end_time;


	uint256 public phase1Supply;
	uint256 public phase2Supply;

	uint256 public phase1PriceInflation;
	uint256 public phase2PriceInflation;

	bool init;

	uint internal _trustedTime;


	function initialize(uint trustedTime) initializer public {
		__AccessControl_init();
		__AccessControlEnumerable_init();
		// upon deployment all roles are assigned to the deployer
		_setupRole(PRESALE_OPERATOR, msg.sender);
		_setupRole(MINTER_ROLE, msg.sender);
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_setupRole(SUPERADMIN_ROLE, msg.sender);
		_setupRole(TREASURY_ROLE, msg.sender);
		_trustedTime = trustedTime;
		_gnosisVault = 0x044e25f98fA9f46BEda68f1469E83dcDBF7C8d4A;
		__AkxPresale_init();

	}

	function __AkxPresale_init() internal onlyInitializing {
	 totalHoldings = 0;
	remainingForPresale = 0;
	numHolders = 0;
	 totalMinted = 0;
	totalLocked = 0;
	 totalBurned = 0;

	init = true;
		pauseContract();
	}

	function __AkxPresale_init_unchained() internal onlyInitializing {}


	function pauseContract() public onlyRole(PRESALE_OPERATOR) {
		super._pause();
	}

	function unpauseContract() public onlyRole(PRESALE_OPERATOR) {
		super._unpause();
	}



	function setVault(address _vault) public onlyRole(PRESALE_OPERATOR) {
		_gnosisVault = _vault;
	}

	function setTimeLocked(address _timeLock) public onlyRole(PRESALE_OPERATOR) {
		timeLockedWallet = _timeLock;
	}

	function setupLockableWallet(address _wal, address _token, uint amount, uint duration) internal {
		lockOnlyAmount(_wal, _token, amount, duration);
	}


	function recordPledge(address _sender, uint256 pledge, uint256 qty, uint256 phaseSupply, uint256 maxHolders) public onlyRole(PRESALE_OPERATOR) {
		require(presalePhase > 0 && presalePhase <= 3, "presale is over");
		validatePledge(_sender, qty, phaseSupply, maxHolders);
		//_token.mint(_sender, qty);
		/// 	event NewHolder(address indexed holder, uint256 qty, uint256 pledged, uint blocknum);
		emit NewHolder(_sender, qty, pledge, block.number);

	}

	function validatePledge(address _sender, uint256 qty, uint256 phaseSupply, uint256 maxHolders) private onlyRole(PRESALE_OPERATOR) returns(uint256)  {

		require(phaseSupply < qty, "pledge amount is too high");
		require(totalMinted < phaseSupply, "wait for next phase to begin");
		require(_holders.length < maxHolders, "phase is already full");

		return 1;

	}




}