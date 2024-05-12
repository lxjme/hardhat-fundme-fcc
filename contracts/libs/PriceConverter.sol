// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // @Param: usdPrce 美元的数值
    // @Result: Wei的数值
    function getConversionPrice(
        uint256 usdPrice,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();

        // price的值是302921246644(由于不能有小数，其实真实数据应该是：1eth = 3029.21221246644美元)
        // 所以需要除以1e8
        // 后面还需要将eth转换为Wei，需要乘以1e18
        // 最终：(50 / (302921246644/1e8)) * 1e18 = 50 * 1e26 / 302921246644
        return uint256((usdPrice * 1e26) / uint256(price));
    }
}
