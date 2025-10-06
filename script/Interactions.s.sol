// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        // Fund the contract
        //vm.startBroadcast();
        console.log("Funding contract at:", mostRecentlyDeployed);
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract with %s", SEND_VALUE);
    }

    function run() external {
        //       uint256 SEND_VALUE = 0.1 ether;
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        console.log(
            "Retrieved most recent FundMe deployment at:",
            mostRecentlyDeployed
        );
        // Check for invalid address
        if (mostRecentlyDeployed == address(0)) {
            revert("No FundMe deployment found for this chain. Deploy first!");
        }

        // Verify the address contains contract code
        require(
            mostRecentlyDeployed.code.length > 0,
            "Address is not a contract"
        );

        // Fund the contract

        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        console.log(
            "Retrieved most recent FundMe deployment at:",
            mostRecentlyDeployed
        );
        // Check for invalid address
        if (mostRecentlyDeployed == address(0)) {
            revert("No FundMe deployment found for this chain. Deploy first!");
        }

        // Verify the address contains contract code
        require(
            mostRecentlyDeployed.code.length > 0,
            "Address is not a contract"
        );

        // Fund the contract
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

    function withdrawFundMe(address mostRecentlyDeployed) public {
        // Fund the contract
        vm.startBroadcast();
        console.log("withdrawing contract at:", mostRecentlyDeployed);

        FundMe(payable(mostRecentlyDeployed)).cheaperwithdraw();
        vm.stopBroadcast();
        //console.log("withdrawed FundMe contract with %s", SEND_VALUE);
    }
}
