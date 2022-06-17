// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import  "@rari-capital/solmate/src/tokens/ERC721.sol";


import "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

	error TokenDoesNotExist();
	error MaxSupplyReached();
	error WrongEtherAmount();
	error MaxAmountPerTrxReached();
	error NoEthBalance();

/// @title ERC721 NFT Drop
/// @title CrazyApes NFT Token
/// @author AKX Lab <info@akxlab.com>
contract CrazyApes is ERC721, Ownable {
	using Strings for uint256;

	uint256 public totalSupply = 0;
	string public baseURI;

	uint256 public immutable maxSupply = 10000;
	uint256 public immutable price = 0.15 ether;
	uint256 public immutable maxAmountPerTrx = 5;

	address public vaultAddress = 0xc956BbcA545e0071Edcd14AE0531F7fa94D33771;

	constructor(
		string memory _name,
		string memory _symbol,
		string memory _baseURI
	) ERC721(_name, _symbol) {
		baseURI = _baseURI;
	}

	/*///////////////////////////////////////////////////////////////
	// MINT FUNCTION
	//////////////////////////////////////////////////////////////*/

	/// @notice Mint NFT function.
	/// @param amount Amount of token that the sender wants to mint.
	function mintNft(uint256 amount) external payable {
		if (amount > maxAmountPerTrx) revert MaxAmountPerTrxReached();
		if (totalSupply + amount > maxSupply) revert MaxSupplyReached();
		if (msg.value < price * amount) revert WrongEtherAmount();

	unchecked {
		for (uint256 index = 0; index < amount; index++) {
			uint256 tokenId = totalSupply + 1;
			_mint(msg.sender, tokenId);
			totalSupply++;
		}
	}
	}

	/*///////////////////////////////////////////////////////////////
	// ETH WITHDRAWAL
	//////////////////////////////////////////////////////////////*/

	/// @notice Withdraw all ETH from the contract to the vault address.
	function withdraw() external onlyOwner {
		if (address(this).balance == 0) revert NoEthBalance();
		SafeTransferLib.safeTransferETH(vaultAddress, address(this).balance);
	}

	function tokenURI(uint256 tokenId)
	public
	view
	override
	returns (string memory)
	{
		if (ownerOf(tokenId) == address(0)) {
			revert TokenDoesNotExist();
		}

		return
		bytes(baseURI).length > 0
		? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
		: "";
	}

}