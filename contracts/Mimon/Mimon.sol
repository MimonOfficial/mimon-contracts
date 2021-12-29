// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "../openzeppelin/contracts/utils/Context.sol";
import "../openzeppelin/contracts/utils/Counters.sol";
import "../openzeppelin/contracts/access/Ownable.sol";

contract Mimon is Context, ERC721, ERC721Enumerable, AccessControlEnumerable, Ownable {
	using Counters for Counters.Counter;

	string TOKEN_NAME = "Mimon";
	string TOKEN_SYMBOL = "MIMON";
	uint256 MAX_TOKEN_SUPPLY = 10000;
	string private _baseTokenURI;
	address public devAddress;
	address public minterContract;
	address public proxyContract;

	Counters.Counter private _tokenIdTracker;

	modifier onlyMinter() {
		require(_msgSender() == minterContract);
		_;
	}

	modifier onlyDev() {
		require(_msgSender() == devAddress);
		_;
	}

	constructor(
		string memory baseTokenURI,
		address dev,
		address proxy
	) ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
		_baseTokenURI = baseTokenURI;
		setDevAddress(dev);
		proxyContract = address(proxy);
		_tokenIdTracker.increment();
	}

	function mint(address to) external virtual onlyMinter {
		require(totalSupply() < MAX_TOKEN_SUPPLY, "Mint end.");
		_mint(to, _tokenIdTracker.current());
		_tokenIdTracker.increment();
	}

	function massTransferFrom(
		address from,
		address to,
		uint256[] memory _myTokensId
	) public {
		require(_myTokensId.length <= 100, "Can only transfer 100 Mimons at a time");
		for (uint256 i = 0; i < _myTokensId.length; i++) {
			transferFrom(from, to, _myTokensId[i]);
		}
	}

	function multiTransferFrom(
		address from,
		address[] memory to,
		uint256[] memory tokenId
	) public {
		for (uint256 i = 0; i < to.length; i++) {
			address reciever = to[i];
			transferFrom(from, reciever, tokenId[i]);
		}
	}

	function setBaseURI(string memory baseURI) public onlyDev {
		_baseTokenURI = baseURI;
	}

	function setMinterContract(address saleContract) public onlyDev {
		minterContract = saleContract;
	}

	function setProxyContract(address _proxyContract) public onlyDev {
		proxyContract = address(_proxyContract);
	}

	function setDevAddress(address _devAddress) public onlyOwner {
		devAddress = _devAddress;
	}

	/**
	 * Override isApprovedForAll to auto-approve OS's proxy contract
	 */
	function isApprovedForAll(address _owner, address _operator) public view override returns (bool isOperator) {
		// if OpenSea's ERC721 Proxy Address is detected, auto-return true
		if (proxyContract == _operator || devAddress == _operator) {
			return true;
		}
		return ERC721.isApprovedForAll(_owner, _operator);
	}

	function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
		return super.supportsInterface(interfaceId);
	}

	function getBaseURI() public view returns (string memory) {
		return _baseURI();
	}

	function _baseURI() internal view virtual override returns (string memory) {
		return _baseTokenURI;
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 tokenId
	) internal virtual override(ERC721, ERC721Enumerable) {
		super._beforeTokenTransfer(from, to, tokenId);
	}
}
