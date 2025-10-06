// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelpConfig helperConfig = new HelpConfig();
        (address ethPriceFeedAddress, uint256 version) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundme = new FundMe(ethPriceFeedAddress, version);
        vm.stopBroadcast();
        return fundme;
    }
}
//
