// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "contracts/libs/PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public minUsd = 50; // 最少50美元
    address[] public funders;
    mapping(address => uint256) public addressToAmmountFunded;
    AggregatorV3Interface private s_priceFeed;
    address public immutable i_owner;

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value >= minUsd.getConversionPrice(s_priceFeed),
            "Didn't send enough usd"
        );

        // 记录下发送人的地址
        funders.push(msg.sender);
        // 记录下发送的金额
        addressToAmmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner");
        if (msg.sender != i_owner) {
            revert FundMe_NotOwner();
        }
        _;
    }
}
