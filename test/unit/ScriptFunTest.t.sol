pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FunWithStorage} from "../../src/FunWithStorage.sol";

import {DeployFunWithStorage} from "../../script/DeployScriptFun.s.sol";

contract ScriptFunTest is Test {
    FunWithStorage funWithStorage;

    function setUp() external {
        DeployFunWithStorage deployFunWithStorage = new DeployFunWithStorage();
        funWithStorage = deployFunWithStorage.run();
        console.log(address(funWithStorage));
    }

    function testPrintStorageData() public {
        for (uint256 i = 0; i < 7; i++) {
            bytes32 value = vm.load(address(funWithStorage), bytes32(i));
            console.log("Value at location", i, ":");
            console.logBytes32(value);
        }
        console.log("funWithStorage address:", address(funWithStorage));
    }

    function testfavoriteNumber() public {
        uint256 favoriteNumber = funWithStorage.getFavoriteNumber();
        assertEq(favoriteNumber, 25);
    }
}
