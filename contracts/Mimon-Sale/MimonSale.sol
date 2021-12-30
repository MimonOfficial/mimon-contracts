// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../openzeppelin/contracts/utils/Context.sol";
import "../openzeppelin/contracts/utils/math/SafeMath.sol";
import "../Mimon/IMimon.sol";

contract MimonSale is Context {
	using SafeMath for uint256;

	IMimon public MimonContract;
	uint256 PRESALE_PRICE = 40000000000000000; // 0.04 Eth
	uint256 PUBLICSALE_PRICE = 60000000000000000; // 0.06 Eth
	uint256 MAX_TOKEN_SUPPLY = 10000;
	uint256 MAX_PRESALE_SUPPLY = 2000;
	uint256 public constant MAX_PRESALE_AMOUNT = 3;
	uint256 public constant MAX_PUBLICSALE_AMOUNT = 15;
	bool public isPreSale = false;
	bool public isPublicSale = false;
	address public C1;
	address public C2;

	mapping (address => uint256) public preSaleCount;

	modifier preSaleRole(uint256 numberOfTokens) {
		require(isPreSale, "The sale has not started.");
		require(MimonContract.totalSupply() < MAX_PRESALE_SUPPLY, "Pre-sale has already ended.");
		require(MimonContract.totalSupply().add(numberOfTokens) <= MAX_PRESALE_SUPPLY, "Pre-sale would exceed max supply of Mimon");
		require(numberOfTokens <= MAX_PRESALE_AMOUNT, "Can only mint 3 Mimon at a time");
		require(preSaleCount[_msgSender()] < MAX_PRESALE_AMOUNT, "Pre-sale max mint amount is 3");
		require(preSaleCount[_msgSender()].add(numberOfTokens) <= MAX_PRESALE_AMOUNT, "Pre-sale max mint amount is 3");
		require(PRESALE_PRICE.mul(numberOfTokens) <= msg.value, "Eth value sent is not correct");
		_;
	}

	modifier publicSaleRole(uint256 numberOfTokens) {
		require(isPublicSale, "The sale has not started.");
		require(MimonContract.totalSupply() < MAX_TOKEN_SUPPLY, "Sale has already ended.");
		require(MimonContract.totalSupply().add(numberOfTokens) <= MAX_TOKEN_SUPPLY, "Purchase would exceed max supply of Mimon");
		require(numberOfTokens <= MAX_PUBLICSALE_AMOUNT, "Can only mint 15 Mimon at a time");
		require(PUBLICSALE_PRICE.mul(numberOfTokens) <= msg.value, "Eth value sent is not correct");
		_;
	}

	/*
    C1: Team, C2: Dev
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
			if (MimonContract.totalSupply() < MAX_TOKEN_SUPPLY) {
				MimonContract.mint(_msgSender());
			}
		}
		preSaleCount[_msgSender()] = preSaleCount[_msgSender()].add(numberOfTokens);
	}

	function publicSale(uint256 numberOfTokens) public payable publicSaleRole(numberOfTokens) {
		for (uint256 i = 0; i < numberOfTokens; i++) {
			if (MimonContract.totalSupply() < MAX_TOKEN_SUPPLY) {
				MimonContract.mint(_msgSender());
			}
		}
	}

	function preMint(uint256 numberOfTokens, address receiver) public onlyCreator {
		for (uint256 i = 0; i < numberOfTokens; i++) {
			if (MimonContract.totalSupply() < MAX_TOKEN_SUPPLY) {
				MimonContract.mint(receiver);
			}
		}
	}

	function withdraw() public payable onlyCreator {
		uint256 contractBalance = address(this).balance;
		uint256 percentage = contractBalance.div(100);

		require(payable(C1).send(percentage.mul(90)));
		require(payable(C2).send(percentage.mul(10)));
	}

	function setC1(address changeAddress) public onlyC1 {
		C1 = changeAddress;
	}

	function setC2(address changeAddress) public onlyC2 {
		C2 = changeAddress;
	}

	function setPreSale() public onlyCreator {
		isPreSale = !isPreSale;
	}

	function setPublicSale() public onlyCreator {
		if (isPreSale == true) {
			setPreSale();
		}
		isPublicSale = !isPublicSale;
	}
}
