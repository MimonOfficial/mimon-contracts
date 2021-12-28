// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../openzeppelin/contracts/utils/Context.sol";
import "../openzeppelin/contracts/utils/math/SafeMath.sol";
import "../Mimon/IMimon.sol";

contract MimonSale is Context {
	using SafeMath for uint256;

	IMimon public MimonContract;
	uint16 MAX_MIMON_SUPPLY = 10000;
	uint256 PRESALE_PRICE = 40000000000000000; // 0.04 Eth
	uint256 PUBLICSALE_PRICE = 60000000000000000; // 0.06 Eth
	uint256 public constant maxClonePurchase = 15;
	bool public isSale = false;
	address public C1;
	address public C2;

	modifier preSaleRole(uint256 numberOfTokens) {
		require(isSale, "The sale has not started.");
		require(MimonContract.totalSupply() < MAX_MIMON_SUPPLY, "Sale has already ended.");
		require(numberOfTokens <= maxClonePurchase, "Can only mint 15 Clones at a time");
		require(MimonContract.totalSupply().add(numberOfTokens) <= MAX_MIMON_SUPPLY, "Purchase would exceed max supply of Mimon");
		require(PRESALE_PRICE.mul(numberOfTokens) <= msg.value, "Eth value sent is not correct");
		_;
	}

	modifier publicSaleRole(uint256 numberOfTokens) {
		require(isSale, "The sale has not started.");
		require(MimonContract.totalSupply() < MAX_MIMON_SUPPLY, "Sale has already ended.");
		require(numberOfTokens <= maxClonePurchase, "Can only mint 15 Clones at a time");
		require(MimonContract.totalSupply().add(numberOfTokens) <= MAX_MIMON_SUPPLY, "Purchase would exceed max supply of Mimon");
		require(PUBLICSALE_PRICE.mul(numberOfTokens) <= msg.value, "Eth value sent is not correct");
		_;
	}

	/*
    C1: Director, C2: Artist, C3: Developer
  */
	modifier onlyCreator() {
		require(C1 == _msgSender() || C2 == _msgSender(), "onlyCreator: caller is not the creator");
		_;
	}

	modifier onlyC1() {
		require(C1 == _msgSender(), "only C1: caller is not the C1");
		_;
	}

	modifier onlyC2() {
		require(C2 == _msgSender(), "only C2: caller is not the C2");
		_;
	}

	constructor(
		address _mimonCA,
		address _C1,
		address _C2
	) {
		MimonContract = IMimon(_mimonCA);
		C1 = _C1;
		C2 = _C2;
	}

	function preSale(uint256 numberOfTokens) public payable preSaleRole(numberOfTokens) {
		for (uint256 i = 0; i < numberOfTokens; i++) {
			if (MimonContract.totalSupply() < MAX_MIMON_SUPPLY) {
				MimonContract.mint(_msgSender());
			}
		}
	}

	function publicSale(uint256 numberOfTokens) public payable publicSaleRole(numberOfTokens) {
		for (uint256 i = 0; i < numberOfTokens; i++) {
			if (MimonContract.totalSupply() < MAX_MIMON_SUPPLY) {
				MimonContract.mint(_msgSender());
			}
		}
	}

	function preMint(uint256 numberOfTokens, address receiver) public onlyCreator {
		require(!isSale, "The sale has started. Can't call preMintClone");
		for (uint256 i = 0; i < numberOfTokens; i++) {
			if (MimonContract.totalSupply() < MAX_MIMON_SUPPLY) {
				MimonContract.mint(receiver);
			}
		}
	}

	function withdraw() public payable onlyCreator {
		uint256 contractBalance = address(this).balance;
		uint256 percentage = contractBalance / 100;

		require(payable(C1).send(percentage * 90));
		require(payable(C2).send(percentage * 10));
	}

	function setC1(address changeAddress) public onlyC1 {
		C1 = changeAddress;
	}

	function setC2(address changeAddress) public onlyC2 {
		C2 = changeAddress;
	}

	function setSale() public onlyCreator {
		isSale = !isSale;
	}
}
