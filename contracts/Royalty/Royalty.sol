// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "../openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../openzeppelin/contracts/utils/Context.sol";
import "../openzeppelin/contracts/utils/math/SafeMath.sol";

contract Royalty is Context {
	using SafeMath for uint256;

	IERC20 public weth;
	address public contractAddress;
	address public C1;
	address public C2;

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
		address _ca,
		address _c1,
		address _c2
	) {
		weth = IERC20(_ca);
		contractAddress = address(this);
		C1 = _c1;
		C2 = _c2;
	}

	function withdrawWeth() public onlyCreator {
		uint256 balance = getWethBalance();
		uint256 transferBalance = SafeMath.div(balance, 100);
		weth.transfer(C1, transferBalance * 85);
		weth.transfer(C2, transferBalance * 15);
	}

	function getWethBalance() public view returns (uint256) {
		return weth.balanceOf(contractAddress);
	}

	function setWeth(address _ca) public onlyC2 {
		weth = IERC20(_ca);
	}

	function setC1(address changeAddress) public onlyC1 {
		C1 = changeAddress;
	}

	function setC2(address changeAddress) public onlyC2 {
		C2 = changeAddress;
	}
}
