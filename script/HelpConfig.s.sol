//spdx-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelpConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant decimals = 8;
    int256 public constant initialAnswer = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
        uint256 version; // price feed version
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthMainnetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig =
            NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, version: 4});
        return sepoliaConfig;
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ETHMainnetConfig =
            NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419, version: 4});
        return ETHMainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(decimals, initialAnswer);
        vm.stopBroadcast();

        NetworkConfig memory AnvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed), version: 4});
        return AnvilConfig;
    }
}
//mock local anvil
