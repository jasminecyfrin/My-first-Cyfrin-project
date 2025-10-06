//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 5 ether; // 0.1 eth = 100000000000000000 wei
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //fundMe = new FundMe(
        //   payable(0x694AA1769357215DE4FAC081bf1f309aDC325306)
        //);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // give USER 10 ETH
    }

    function testMINIMUMUSDISFIVE() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testiOwnerIsMessageSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersion() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testNotEnoughETH() public {
        vm.expectRevert(); // hey, the next line shall be revert
        fundMe.fund(); // zero value sent, less than minimum
    }

    function testEnoughETH() public {
        vm.prank(USER); // the next tx will be sent by USER

        fundMe.fund{value: SEND_VALUE}(); // send 5 ETH
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testFundersArray() public {
        vm.prank(USER); // the next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // send 5 ETH

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER); // the next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // send 5 ETH
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); // hey, the next line shall be revert
        vm.prank(USER);
        fundMe.withdraw();

        // only the contract owner can withdraw, not funders
    }

    function testWithdraw() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testPrintStorageData() public {
        for (uint256 i = 0; i < 3; i++) {
            bytes32 value = vm.load(address(fundMe), bytes32(i));
            console.log("Value at location", i, ":");
            console.logBytes32(value);
        }
        console.log("PriceFeed address:", address(fundMe.getPriceFeed()));
    }

    function testWithDrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(address(i)); // give each funder 10 ETH
            // vm.deal(address(i), STARTING_BALANCE);
            hoax(address(i), STARTING_BALANCE); // give each funder 10 ETH and prank the next tx to be sent by this address
            fundMe.fund{value: SEND_VALUE}(); // each funder sends 5 ETH
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); // set gas price to 1 wei
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        uint256 txCost = (gasStart - gasEnd) * tx.gasprice;
        console.log(tx.gasprice);
        console.log("Gas cost of withdraw from multiple funders", txCost);

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }

    // import {DeployFundMe} from "../script/DeployFundMe.s.sol";
    // import {HelperConfig} from "../script/HelperConfig.s.sol";
    // import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol

    function testWithDrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(address(i)); // give each funder 10 ETH
            // vm.deal(address(i), STARTING_BALANCE);
            hoax(address(i), STARTING_BALANCE); // give each funder 10 ETH and prank the next tx to be sent by this address
            fundMe.fund{value: SEND_VALUE}(); // each funder sends 5 ETH
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); // set gas price to 1 wei
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperwithdraw();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        uint256 txCost = (gasStart - gasEnd) * tx.gasprice;
        console.log(tx.gasprice);
        console.log("Gas cost of withdraw from multiple funders", txCost);

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }
}
