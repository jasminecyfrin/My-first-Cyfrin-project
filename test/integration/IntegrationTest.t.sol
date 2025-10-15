//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 5 ether; // 0.1 eth = 100000000000000000 wei
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // give USER 10 ETH
        //console.log(fundMe);
        console.log("Setup-fundMe address %s", address(fundMe));
    }

    function testFundInteraction() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdraw = new WithdrawFundMe();
        withdraw.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }

    //   vm.prank(USER);
    //   fundMe.fund{value: SEND_VALUE}();

    //   address funder = fundMe.getFunder(0);
    //  assertEq(funder, USER);
    //  uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    //  assertEq(amountFunded, SEND_VALUE);
    // }

    function testWithdrawInteraction() public {
        // TestFundInteraction();
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperwithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    //function testWithdrawInteractionNoOwner() public {
    // TestFundInteraction();

    //vm.prank(USER);
    //     fundMe.cheaperwithdraw();
    //    vm.expectRevert();
    // }
}
